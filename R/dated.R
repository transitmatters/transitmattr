#' Get headway data for a date
#'
#' @param user_date A `Date` object or a `"YYYY-MM-DD"` string.
#' @param stops A character vector of stop IDs to filter by. If `NULL` (default),
#'   returns data for all stops.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with a `headways` element containing per-route headway data.
#' @export
#' @examples
#' \dontrun{
#' tm_headways("2024-01-15")
#' tm_headways("2024-01-15", stops = "70061")
#' tm_headways(as.Date("2024-01-15"), stops = c("70061", "70063"))
#' }
tm_headways <- function(user_date, stops = NULL, base_url = tm_base_url()) {
  tm_request(
    c("api", "headways", .tm_date(user_date)),
    query = list(stop = stops),
    base_url = base_url
  )
}

#' Get dwell time data for a date
#'
#' @inheritParams tm_headways
#' @return A list with a `dwells` element containing per-route dwell data.
#' @export
#' @examples
#' \dontrun{
#' tm_dwells("2024-01-15")
#' tm_dwells("2024-01-15", stops = "70061")
#' }
tm_dwells <- function(user_date, stops = NULL, base_url = tm_base_url()) {
  tm_request(
    c("api", "dwells", .tm_date(user_date)),
    query = list(stop = stops),
    base_url = base_url
  )
}

#' Get travel time data for a date
#'
#' @param user_date A `Date` object or a `"YYYY-MM-DD"` string.
#' @param from_stops A character vector of origin stop IDs to filter by.
#' @param to_stops A character vector of destination stop IDs to filter by.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with a `travel_times` element containing per-segment travel
#'   time data.
#' @export
#' @examples
#' \dontrun{
#' tm_travel_times("2024-01-15")
#' tm_travel_times("2024-01-15", from_stops = "70061", to_stops = "70063")
#' }
tm_travel_times <- function(user_date, from_stops = NULL, to_stops = NULL, base_url = tm_base_url()) {
  tm_request(
    c("api", "traveltimes", .tm_date(user_date)),
    query = list(from_stop = from_stops, to_stop = to_stops),
    base_url = base_url
  )
}

#' Get MBTA service alerts
#'
#' When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
#' returning current alerts. Pass a date to retrieve alerts for a specific day.
#'
#' @param user_date A `Date` object, a `"YYYY-MM-DD"` string, or `NULL`
#'   (default) for current alerts.
#' @param routes A character vector of route IDs to filter by (e.g.
#'   `"Red"`, `c("Red", "Orange")`). If `NULL` (default), all alerts are
#'   returned. Only used when `user_date` is supplied.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with an `alerts` element.
#' @export
#' @examples
#' \dontrun{
#' tm_alerts()
#' tm_alerts("2024-01-15")
#' tm_alerts("2024-01-15", routes = "Red")
#' tm_alerts("2024-01-15", routes = c("Red", "Orange"))
#' }
tm_alerts <- function(user_date = NULL, routes = NULL, base_url = tm_base_url()) {
  if (is.null(user_date)) {
    tm_request("api/alerts", base_url = base_url)
  } else {
    tm_request(
      c("api", "alerts", .tm_date(user_date)),
      query = list(route = routes),
      base_url = base_url
    )
  }
}
