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

# Cold starts of the API's Lambda functions show up as these statuses.
.tm_retry_statuses <- c(429L, 500L, 503L)

#' @noRd
.tm_sleep <- function(seconds) Sys.sleep(seconds)

#' @noRd
.tm_user_agent <- function() {
  paste0("transitmattr/", utils::packageVersion("transitmattr"))
}

#' @noRd
.tm_body_text <- function(resp) {
  # The generated code puts a string rather than raw bytes in `response` when
  # a 5xx body is empty.
  if (is.character(resp$response)) return(resp$response)
  resp$response_as_text()
}

# Raise the error httr2 would have, with classes `httr2_http_<status>`,
# `httr2_http`, and `httr2_error`, so callers can keep catching those.
#' @noRd
.tm_http_error <- function(resp, body) {
  status <- resp$status_code
  message <- paste0("HTTP ", status, " ", resp$status_code_desc, ".")
  if (nzchar(body)) message <- paste0(message, "\n", body)
  stop(structure(
    class = c(paste0("httr2_http_", status), "httr2_http", "httr2_error",
              "error", "condition"),
    list(message = message, call = NULL, status = status, body = body)
  ))
}

# Call one operation of the generated ApiApi, e.g. "get_headways", with the
# arguments in `...` (NULLs are dropped). Retries cold starts, raises an
# `httr2_http_<status>` error for any status not in `ok`, and returns the
# parsed JSON body.
#' @noRd
.tm_call <- function(operation, ..., base_url = tm_base_url(), simplify = FALSE,
                     ok = 200L, max_tries = 3L) {
  client <- ApiClient$new(base_path = base_url, user_agent = .tm_user_agent())
  method <- ApiApi$new(client)[[paste0(operation, "_with_http_info")]]
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

  for (attempt in seq_len(max_tries)) {
    resp <- do.call(method, args)
    status <- resp$status_code
    retry <- !status %in% ok && status %in% .tm_retry_statuses
    if (!retry || attempt == max_tries) break
    .tm_sleep(2^attempt)
  }

  # The generated code wraps 4xx responses in a second ApiResponse.
  if (inherits(resp$response, "ApiResponse")) resp <- resp$response
  body <- .tm_body_text(resp)
  if (!status %in% ok) .tm_http_error(resp, body)
  jsonlite::fromJSON(body, simplifyVector = simplify)
}
