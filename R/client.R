#' @section Options:
#' * `tm_dashboard_base_url`: the API's base URL. Defaults to the production
#'   API.
#' * `transitmattr.max_concurrency`: how many requests to have in flight at
#'   once when a call makes several, such as `$headways()` over a date range.
#'   Defaults to 8.
#' @keywords internal
#' @import httr2
#' @importFrom R6 R6Class
"_PACKAGE"

# The generated ApiClient and ApiApi (R/generated-*.R) call these without a
# namespace prefix.
#' @importFrom stringr str_detect
#' @importFrom utils URLencode
NULL

#' @noRd
tm_base_url <- function() {
  getOption(
    "tm_dashboard_base_url",
    "https://dashboard-api.labs.transitmatters.org"
  )
}

#' @noRd
.tm_gtfs_line_id <- function(x) {
  # Produces "line-Red", "line-Orange", etc. (DynamoDB key format)
  color <- sub("^line-", "", tolower(x))
  paste0("line-", toupper(substr(color, 1, 1)), substr(color, 2, nchar(color)))
}

#' @noRd
.tm_line_color <- function(x) {
  # Produces "Red", "Orange", etc. (delays/trip-metrics format, no prefix)
  color <- sub("^line-", "", x)
  paste0(toupper(substr(color, 1, 1)), substr(color, 2, nchar(color)))
}

#' @noRd
.tm_date <- function(x) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "Date")) format(x, "%Y-%m-%d") else as.character(x)
}

# Every operation in the generated ApiApi, and what wraps it. A test checks
# this against ApiApi, so a new upstream endpoint fails until it's wrapped.
.tm_wrapped_ops <- c(
  get_aggregate_dwells            = "$aggregate_dwells()",
  get_aggregate_headways          = "$aggregate_headways()",
  get_aggregate_travel_times      = "$aggregate_travel_times()",
  get_aggregate_travel_times_v2   = "$aggregate_travel_times_v2()",
  get_bus_speed_leaderboard       = "tm_bus_speed_leaderboard()",
  get_bus_trip_metrics            = "TmBusQuery$trip_metrics()",
  get_commuter_rail_scorecard     = "TmCRQuery$scorecard()",
  get_commuter_rail_trip_metrics  = "TmCRQuery$trip_metrics()",
  get_current_alerts              = "tm_alerts()",
  get_dwells                      = "$dwells()",
  get_facilities                  = "tm_facilities()",
  get_headways                    = "$headways()",
  get_healthcheck                 = "tm_healthcheck()",
  get_historical_alerts           = "tm_alerts(user_date)",
  get_line_delays                 = "TmRTQuery$line_delays()",
  get_reliability                 = "tm_reliability(), TmCRQuery$reliability()",
  get_ridership                   = "TmRTQuery$ridership()",
  get_routes                      = "tm_routes()",
  get_scheduled_service           = "tm_scheduled_service(), TmRTQuery$scheduled_service()",
  get_service_hours               = "TmRTQuery$service_hours()",
  get_service_ridership_dashboard = "tm_service_ridership_dashboard()",
  get_speed_restrictions          = "TmRTQuery$speed_restrictions()",
  get_stops_for_route             = "tm_stops()",
  get_time_predictions            = "tm_time_predictions()",
  get_travel_times                = "$travel_times()",
  get_trip_metrics                = "TmRTQuery$trip_metrics()",
  get_weather                     = "tm_weather()"
)

# Statuses worth retrying: rate limiting, and the API's Lambda functions
# timing out or starting cold. A 500 usually means the request itself is bad.
.tm_retry_statuses <- c(429L, 502L, 503L, 504L)

#' @noRd
.tm_user_agent <- function() {
  paste0("transitmattr/", utils::packageVersion("transitmattr"))
}

# Seconds to wait before retry `attempt`: exponential with jitter, capped at
# 8 seconds. httr2 waits as long as a Retry-After header says instead.
#' @noRd
.tm_backoff <- function(attempt) {
  delay <- min(8, 0.5 * 2^attempt)
  delay / 2 + stats::runif(1, 0, delay / 2)
}

# The generated ApiClient builds each request and sends it in Execute(). This
# subclass keeps the finished request instead of sending it, by running
# Execute() with httr2's mock hook catching the request, so .tm_perform() can
# send it, alone or in parallel with others, with httr2's retries.
TmRequestBuilder <- R6::R6Class(
  "TmRequestBuilder",
  inherit = ApiClient,
  public = list(
    request = NULL,
    Execute = function(req, ...) {
      httr2::with_mocked_responses(
        function(req) {
          self$request <- req
          httr2::response(200L)
        },
        super$Execute(req, ...)
      )
    }
  )
)

# Build the request for one operation of the generated ApiApi, e.g.
# "get_headways", with the arguments in `...` (NULLs are dropped).
#' @noRd
.tm_request <- function(operation, ..., base_url = tm_base_url()) {
  builder <- TmRequestBuilder$new(base_path = base_url,
                                  user_agent = .tm_user_agent())
  method <- ApiApi$new(builder)[[paste0(operation, "_with_http_info")]]
  if (!is.function(method)) {
    stop("The API has no operation `", operation, "`.", call. = FALSE)
  }

  args <- Filter(Negate(is.null), list(...))
  # The generated methods take `...`, so a misspelled or renamed parameter
  # would otherwise be dropped without a word.
  unknown <- setdiff(names(args), names(formals(method)))
  if (length(unknown)) {
    stop("`", operation, "` has no parameter ",
         paste0("`", unknown, "`", collapse = ", "),
         ". The API spec may have changed.", call. = FALSE)
  }
  args$.parse <- FALSE
  do.call(method, args)

  req <- httr2::req_timeout(builder$request, 30)
  req <- httr2::req_retry(
    req,
    max_tries = 4,
    retry_on_failure = TRUE,
    is_transient = function(resp) httr2::resp_status(resp) %in% .tm_retry_statuses,
    backoff = function(attempt) .tm_backoff(attempt)
  )
  # Statuses are checked in .tm_perform(), to raise transitmattr's errors.
  httr2::req_error(req, is_error = function(resp) FALSE)
}

# Send requests built by .tm_request() for `operation`, several at once when
# there are several, and return their bodies as text. Raises a
# transitmattr_error (see ?transitmattr_errors) for any status not in `ok` or
# request that got no response.
#' @noRd
.tm_perform <- function(reqs, operation, ok = 200L) {
  max_active <- getOption("transitmattr.max_concurrency", 8L)
  resps <- if (length(reqs) == 1 || max_active == 1) {
    lapply(reqs, function(req) {
      tryCatch(httr2::req_perform(req),
               httr2_failure = function(failure) failure)
    })
  } else {
    httr2::req_perform_parallel(
      reqs,
      on_error = "continue",
      max_active = max_active,
      progress = interactive()
    )
  }
  lapply(resps, function(resp) {
    if (inherits(resp, "httr2_failure")) .tm_network_error(resp, operation)
    if (!httr2::resp_status(resp) %in% ok) .tm_http_error(resp, operation)
    if (httr2::resp_has_body(resp)) httr2::resp_body_string(resp) else "null"
  })
}

# Call one operation of the generated ApiApi, e.g. "get_headways", with the
# arguments in `...`, and return the parsed body with its fields converted
# (see R/convert.R).
#' @noRd
.tm_call <- function(operation, ..., base_url = tm_base_url(), simplify = FALSE,
                     ok = 200L) {
  req <- .tm_request(operation, ..., base_url = base_url)
  body <- .tm_perform(list(req), operation, ok = ok)[[1]]
  .tm_convert(jsonlite::fromJSON(body, simplifyVector = simplify),
              .tm_response_model(operation))
}

# Call one operation several times in parallel: once per element of
# `varying`, a list of argument lists, each with the arguments in `...`.
# `combine` joins the parsed bodies before their fields are converted.
#' @noRd
.tm_call_each <- function(operation, varying, ..., base_url = tm_base_url(),
                          simplify = FALSE, combine = .tm_bind_rows) {
  shared <- list(...)
  reqs <- lapply(varying, function(args) {
    do.call(.tm_request, c(list(operation), args, shared,
                           list(base_url = base_url)))
  })
  bodies <- .tm_perform(reqs, operation)
  parts <- lapply(bodies, jsonlite::fromJSON, simplifyVector = simplify)
  .tm_convert(combine(parts), .tm_response_model(operation))
}
