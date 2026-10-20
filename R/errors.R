#' Errors raised by transitmattr
#'
#' When a request fails, transitmattr raises an error with one of these
#' classes, so you can handle each kind of failure with [tryCatch()]:
#'
#' ```
#' transitmattr_error
#' |-- transitmattr_http_error       the API responded with an error status
#' |   |-- transitmattr_bad_request    400: a parameter is missing or invalid
#' |   |-- transitmattr_range_too_long 403: the date range has too many entries
#' |   |-- transitmattr_not_found      404: no route has this ID
#' |   `-- transitmattr_server_error   5xx: the API failed
#' `-- transitmattr_network_error    no response: a timeout or failed connection
#' ```
#'
#' HTTP errors have fields `status` (the HTTP status code), `code` (the error
#' type the API reported, such as `"ForbiddenError"`, or `NULL`), and
#' `content` (the response body as text). They also have httr2's classes
#' `httr2_http_<status>`, `httr2_http`, and `httr2_error`, so handlers written
#' for earlier versions keep working.
#'
#' Requests that time out, fail to connect, or get a 429, 502, 503, or 504
#' response are retried up to three times before an error is raised.
#'
#' @name transitmattr_errors
#' @examples
#' \dontrun{
#' tryCatch(
#'   tm_stops("Purple"),
#'   transitmattr_not_found = function(e) {
#'     message("No such route: ", conditionMessage(e))
#'     NULL
#'   }
#' )
#' }
NULL

# Raise the error for an HTTP response whose status isn't a success.
#' @noRd
.tm_http_error <- function(resp, operation) {
  status <- httr2::resp_status(resp)
  body <- if (httr2::resp_has_body(resp)) httr2::resp_body_string(resp) else ""
  details <- .tm_error_details(body)
  kind <- if (status == 400) {
    "transitmattr_bad_request"
  } else if (status == 403) {
    # Only the trip metrics endpoints and the bus speed leaderboard document
    # a 403, for date ranges with too many entries.
    "transitmattr_range_too_long"
  } else if (status == 404) {
    "transitmattr_not_found"
  } else if (status >= 500) {
    "transitmattr_server_error"
  }
  heading <- paste0("HTTP ", status, " ", httr2::resp_status_desc(resp))
  if (!is.null(details$code)) heading <- paste0(heading, " (", details$code, ")")
  message <- c(paste0(heading, " from `", operation, "`."))
  if (nzchar(details$message)) message <- c(message, x = details$message)
  if (identical(kind, "transitmattr_range_too_long")) {
    message <- c(message, i = "Request a shorter date range.")
  }
  rlang::abort(
    message,
    class = c(kind, "transitmattr_http_error", "transitmattr_error",
              paste0("httr2_http_", status), "httr2_http", "httr2_error"),
    status = status,
    code = details$code,
    # Not `body`, which rlang::abort() would print as part of the message.
    content = body,
    call = NULL
  )
}

# The API's own description of an error: ErrorResponse has `Code` and
# `Message`, RouteNotFoundResponse has `error`, and anything else is reported
# as-is.
#' @noRd
.tm_error_details <- function(body) {
  parsed <- tryCatch(jsonlite::fromJSON(body, simplifyVector = FALSE),
                     error = function(e) NULL)
  if (is.list(parsed) && is.character(parsed$Message)) {
    return(list(code = parsed$Code, message = parsed$Message))
  }
  if (is.list(parsed) && is.character(parsed$error)) {
    return(list(code = NULL, message = parsed$error))
  }
  list(code = NULL, message = trimws(body))
}

# Raise the error for a request that got no response at all.
#' @noRd
.tm_network_error <- function(failure, operation) {
  url <- failure$request$url
  rlang::abort(
    paste0("No response from the API for `", operation, "`",
           if (!is.null(url)) paste0(" (", url, ")"), "."),
    class = c("transitmattr_network_error", "transitmattr_error"),
    parent = failure,
    call = NULL
  )
}
