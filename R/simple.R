#' Check API health
#'
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with fields `status` (string) and optionally `failed_checks`.
#' @export
#' @examples
#' \dontrun{
#' tm_healthcheck()
#' }
tm_healthcheck <- function(base_url = tm_base_url()) {
  tm_request("api/healthcheck", base_url = base_url)
}

#' Get the deployed git commit ID
#'
#' @inheritParams tm_healthcheck
#' @return A list with the git commit SHA of the running server.
#' @export
#' @examples
#' \dontrun{
#' tm_git_id()
#' }
tm_git_id <- function(base_url = tm_base_url()) {
  tm_request("api/git_id", base_url = base_url)
}

#' List MBTA facilities
#'
#' @inheritParams tm_healthcheck
#' @return A list of facility objects.
#' @export
#' @examples
#' \dontrun{
#' tm_facilities()
#' }
tm_facilities <- function(base_url = tm_base_url()) {
  tm_request("api/facilities", base_url = base_url)
}

#' Get time prediction accuracy data for a route
#'
#' @param route_id MBTA route identifier, e.g. `"Red"` or `"CR-Fairmount"`.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list of time prediction objects.
#' @export
#' @examples
#' \dontrun{
#' tm_time_predictions("Red")
#' tm_time_predictions("CR-Fairmount")
#' }
tm_time_predictions <- function(route_id, base_url = tm_base_url()) {
  tm_request(
    "api/time_predictions",
    query = list(route_id = route_id),
    base_url = base_url
  )
}

#' List all available routes
#'
#' Returns a manifest of all routes supported by the TransitMatters dashboard,
#' grouped by transit mode.
#'
#' @inheritParams tm_healthcheck
#' @return A list with elements `rapid_transit`, `bus`, `commuter_rail`, and
#'   `ferry`, each containing a character vector of route IDs.
#' @export
#' @examples
#' \dontrun{
#' tm_routes()
#' }
tm_routes <- function(base_url = tm_base_url()) {
  tm_request("api/routes", base_url = base_url)
}

#' Get stop information for a route
#'
#' Returns station and stop data for the given route, including names, IDs,
#' and directions.
#'
#' @param route_id MBTA route identifier, e.g. `"Red"` or `"CR-Fairmount"`.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with elements `type`, `direction`, `stations`, and optionally
#'   `service_start` and `service_end`.
#' @export
#' @examples
#' \dontrun{
#' tm_stops("Red")
#' tm_stops("CR-Fairmount")
#' }
tm_stops <- function(route_id, base_url = tm_base_url()) {
  tm_request(c("api", "stops", route_id), base_url = base_url)
}

#' Get the service ridership dashboard summary
#'
#' @inheritParams tm_healthcheck
#' @return A list containing the service ridership dashboard data.
#' @export
#' @examples
#' \dontrun{
#' tm_service_ridership_dashboard()
#' }
tm_service_ridership_dashboard <- function(base_url = tm_base_url()) {
  tm_request("api/service_ridership_dashboard", base_url = base_url)
}
