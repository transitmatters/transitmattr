#' Get headway data for a date
#'
#' @param user_date A `Date` object or a `"YYYY-MM-DD"` string.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with a `headways` element containing per-route headway data.
#' @export
#' @examples
#' \dontrun{
#' tm_headways("2024-01-15")
#' tm_headways(as.Date("2024-01-15"))
#' }
tm_headways <- function(user_date, base_url = tm_base_url()) {
  tm_request(c("api", "headways", .tm_date(user_date)), base_url = base_url)
}

#' Get dwell time data for a date
#'
#' @inheritParams tm_headways
#' @return A list with a `dwells` element containing per-route dwell data.
#' @export
#' @examples
#' \dontrun{
#' tm_dwells("2024-01-15")
#' }
tm_dwells <- function(user_date, base_url = tm_base_url()) {
  tm_request(c("api", "dwells", .tm_date(user_date)), base_url = base_url)
}

#' Get travel time data for a date
#'
#' @inheritParams tm_headways
#' @return A list with a `travel_times` element containing per-segment travel
#'   time data.
#' @export
#' @examples
#' \dontrun{
#' tm_travel_times("2024-01-15")
#' }
tm_travel_times <- function(user_date, base_url = tm_base_url()) {
  tm_request(c("api", "traveltimes", .tm_date(user_date)), base_url = base_url)
}

#' Get MBTA service alerts
#'
#' When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
#' returning current alerts. Pass a date to retrieve alerts for a specific day.
#'
#' @param user_date A `Date` object, a `"YYYY-MM-DD"` string, or `NULL`
#'   (default) for current alerts.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with an `alerts` element.
#' @export
#' @examples
#' \dontrun{
#' tm_alerts()
#' tm_alerts("2024-01-15")
#' }
tm_alerts <- function(user_date = NULL, base_url = tm_base_url()) {
  path <- if (is.null(user_date)) "api/alerts"
          else c("api", "alerts", .tm_date(user_date))
  tm_request(path, base_url = base_url)
}
