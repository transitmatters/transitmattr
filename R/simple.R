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

#' List all available routes
#'
#' @inheritParams tm_healthcheck
#' @return A list with elements `rapid_transit`, `bus`, `commuter_rail`, and
#'   `ferry`, each containing the routes available in that category.
#' @export
#' @examples
#' \dontrun{
#' tm_routes()
#' }
tm_routes <- function(base_url = tm_base_url()) {
  tm_request("api/routes", base_url = base_url)
}

#' Get MBTA service alerts
#'
#' When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
#' returning current live alerts. Pass a date to retrieve historical alerts,
#' optionally filtered by route.
#'
#' @param user_date A `Date` object, a `"YYYY-MM-DD"` string, or `NULL`
#'   (default) for current alerts.
#' @param route One or more MBTA route IDs (e.g. `"Red"`, `"Orange"`). Only
#'   used when `user_date` is provided.
#' @param base_url Base URL of the TransitMatters API.
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

#' Get stops for a route from the API
#'
#' Returns live stop data from the API for a given route. For local lookups
#' backed by embedded data, use the `$stations()` method on a query object.
#'
#' @param route_id An MBTA route ID string (e.g. `"Red"`, `"CR-Fairmount"`).
#' @param base_url Base URL of the TransitMatters API.
#' @return A list with `type`, `direction`, and `stations` elements.
#' @export
#' @examples
#' \dontrun{
#' tm_stops("Red")
#' }
tm_stops <- function(route_id, base_url = tm_base_url()) {
  tm_request(c("api", "stops", route_id), base_url = base_url)
}

#' Get current time predictions
#'
#' Returns time prediction accuracy data for an MBTA route.
#'
#' @param route_id Route identifier, e.g. `"Red"`, `"CR-Fairmount"`.
#' @param base_url Base URL of the TransitMatters API.
#' @return A list with a `predictions` field.
#' @export
#' @examples
#' \dontrun{
#' tm_time_predictions("Red")
#' }
tm_time_predictions <- function(route_id, base_url = tm_base_url()) {
  tm_request(
    "api/time_predictions",
    query = list(route_id = route_id),
    base_url = base_url
  )
}

#' Get scheduled service data
#'
#' Returns scheduled service counts aggregated over a date range.
#'
#' @param start_date Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.
#' @param end_date End of the date range.
#' @param agg Aggregation level: `"daily"` or `"weekly"`.
#' @param route_id Optional MBTA route ID (e.g. `"Red"`, `"Green-B"`). When
#'   `NULL`, returns data for all routes.
#' @param base_url Base URL of the TransitMatters API.
#' @return A list of scheduled service records.
#' @export
#' @examples
#' \dontrun{
#' tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily", route_id = "Red")
#' }
tm_scheduled_service <- function(start_date, end_date, agg, route_id = NULL,
                                 base_url = tm_base_url()) {
  tm_request(
    "api/scheduledservice",
    query = list(
      start_date = .tm_date(start_date),
      end_date   = .tm_date(end_date),
      agg        = agg,
      route_id   = route_id
    ),
    base_url = base_url
  )
}
