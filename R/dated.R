#' Get headway data for a date
#'
#' @param user_date A `Date` object or a `"YYYY-MM-DD"` string.
#' @param stop One or more stop IDs (required). Use [tm_stops()] to find IDs.
#'   Pass a character vector for multiple stops.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return An unnamed list of headway event records. Each record contains
#'   `route_id`, `direction`, `current_dep_dt`, `headway_time_sec`,
#'   `benchmark_headway_time_sec`, `vehicle_label`, and `vehicle_consist`.
#'   Use `dplyr::bind_rows(result)` to convert to a data frame.
#' @export
#' @examples
#' \dontrun{
#' tm_headways("2024-01-15", stop = "70061")
#' tm_headways(as.Date("2024-01-15"), stop = c("70061", "70063"))
#' }
tm_headways <- function(user_date, stop, base_url = tm_base_url()) {
  tm_request(c("api", "headways", .tm_date(user_date)),
    query = list(stop = stop), base_url = base_url)
}

#' Get dwell time data for a date
#'
#' @inheritParams tm_headways
#' @return An unnamed list of dwell event records. Use `dplyr::bind_rows(result)`
#'   to convert to a data frame.
#' @export
#' @examples
#' \dontrun{
#' tm_dwells("2024-01-15", stop = "70061")
#' }
tm_dwells <- function(user_date, stop, base_url = tm_base_url()) {
  tm_request(c("api", "dwells", .tm_date(user_date)),
    query = list(stop = stop), base_url = base_url)
}

#' Get travel time data for a date
#'
#' @param user_date A `Date` object or a `"YYYY-MM-DD"` string.
#' @param from_stop One or more origin stop IDs (required). Use [tm_stops()] to
#'   find IDs.
#' @param to_stop One or more destination stop IDs (required).
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return An unnamed list of travel time event records. Use
#'   `dplyr::bind_rows(result)` to convert to a data frame.
#' @export
#' @examples
#' \dontrun{
#' tm_travel_times("2024-01-15", from_stop = "70076", to_stop = "70064")
#' }
tm_travel_times <- function(user_date, from_stop, to_stop,
                            base_url = tm_base_url()) {
  tm_request(c("api", "traveltimes", .tm_date(user_date)),
    query = list(from_stop = from_stop, to_stop = to_stop), base_url = base_url)
}

#' Get MBTA service alerts
#'
#' When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
#' returning current live alerts (no parameters accepted). Pass a date to
#' retrieve historical alerts for a specific day, optionally filtered by route.
#'
#' @param user_date A `Date` object, a `"YYYY-MM-DD"` string, or `NULL`
#'   (default) for current alerts.
#' @param route One or more MBTA route IDs (e.g. `"Red"`, `"Orange"`). Only
#'   used when `user_date` is provided. Use [tm_routes()] to list valid IDs.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with an `alerts` element.
#' @export
#' @examples
#' \dontrun{
#' tm_alerts()
#' tm_alerts("2024-01-15", route = "Red")
#' }
tm_alerts <- function(user_date = NULL, route = NULL, base_url = tm_base_url()) {
  if (is.null(user_date)) {
    tm_request("api/alerts", base_url = base_url)
  } else {
    tm_request(
      c("api", "alerts", .tm_date(user_date)),
      query = list(route = route),
      base_url = base_url
    )
  }
}

#' Get stops for a route
#'
#' @param route_id An MBTA route ID string (e.g. `"Red"`, `"Orange"`,
#'   `"Green-B"`, `"CR-Fairmount"`). Use [tm_routes()] to list all valid IDs.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with `type`, `direction`, and `stations` elements.
#' @export
#' @examples
#' \dontrun{
#' tm_stops("Red")
#' tm_stops("Green-B")
#' }
tm_stops <- function(route_id, base_url = tm_base_url()) {
  tm_request(c("api", "stops", route_id), base_url = base_url)
}
