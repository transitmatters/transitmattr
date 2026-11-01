#' Check API health
#'
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with fields `status` (`"pass"` or `"fail"`) and, when checks
#'   fail, `failed_checks`.
#' @export
#' @examples
#' \dontrun{
#' tm_healthcheck()
#' }
tm_healthcheck <- function(base_url = tm_base_url()) {
  # A failing healthcheck is a 500 with the usual body, not an error.
  .tm_call("get_healthcheck", base_url = base_url, ok = c(200L, 500L))
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
  .tm_call("get_facilities", base_url = base_url)
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
  .tm_call("get_service_ridership_dashboard", base_url = base_url)
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
  .tm_call("get_routes", base_url = base_url)
}

#' Get MBTA service alerts
#'
#' When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
#' returning current live alerts. Pass a date to retrieve historical alerts,
#' optionally filtered by route, and an `end_date` to retrieve them for every
#' day from `user_date` through `end_date`.
#'
#' Alert times are `POSIXct` date-times in Eastern time.
#'
#' @param user_date A `Date` object, a `"YYYY-MM-DD"` string, or `NULL`
#'   (default) for current alerts.
#' @param route One or more MBTA route IDs (e.g. `"Red"`, `"Orange"`). Only
#'   used when `user_date` is provided.
#' @param end_date Optional last date of a range of historical alerts.
#' @param base_url Base URL of the TransitMatters API.
#' @return A list of alerts. Historical alerts have `valid_from`, `valid_to`,
#'   and `text`; current alerts have `id`, `type`, `header`, `active_period`,
#'   `stops`, `routes`, and `description`.
#' @export
#' @examples
#' \dontrun{
#' tm_alerts()
#' tm_alerts("2024-01-15", route = "Red")
#' tm_alerts("2024-01-15", route = "Red", end_date = "2024-01-21")
#' }
tm_alerts <- function(user_date = NULL, route = NULL, end_date = NULL,
                      base_url = tm_base_url()) {
  if (is.null(user_date)) {
    return(.tm_call("get_current_alerts", base_url = base_url))
  }
  days <- if (is.null(end_date)) .tm_date(user_date) else .tm_days(user_date, end_date)
  .tm_call_each(
    "get_historical_alerts",
    lapply(days, function(d) list(user_date = d)),
    route = route,
    base_url = base_url,
    combine = function(parts) do.call(c, parts)
  )
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
  .tm_call("get_stops_for_route", route_id = route_id, base_url = base_url)
}

#' Get prediction accuracy by week
#'
#' Returns how accurate the MBTA's arrival and departure predictions were for
#' a route, week by week. Pass `start_date` and `end_date` to return only the
#' weeks starting in that range; omit them for the full history.
#'
#' @param route_id Route identifier, e.g. `"Red"`, `"CR-Fairmount"`.
#' @param start_date Optional. Return only weeks starting on or after this
#'   date. A `Date` object or `"YYYY-MM-DD"` string.
#' @param end_date Optional. Return only weeks starting on or before this date.
#' @param base_url Base URL of the TransitMatters API.
#' @return A list with one element per week, each with `routeId`, `week` (a
#'   `Date`), and `prediction`: a list of accuracy buckets with `bin` (how far
#'   ahead the prediction was, e.g. `"0-3 min"`), `num_predictions`, and
#'   `num_accurate_predictions`.
#' @export
#' @examples
#' \dontrun{
#' tm_time_predictions("Red")
#' tm_time_predictions("Red", "2026-06-01", "2026-07-31")
#' }
tm_time_predictions <- function(route_id, start_date = NULL, end_date = NULL,
                                base_url = tm_base_url()) {
  .tm_call("get_time_predictions",
    route_id   = route_id,
    start_date = .tm_date(start_date),
    end_date   = .tm_date(end_date),
    base_url   = base_url
  )
}

#' Get scheduled service data
#'
#' Returns scheduled service counts aggregated over a date range.
#'
#' @param start_date Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.
#' @param end_date End of the date range.
#' @param agg Aggregation level: `"daily"`, `"weekly"`, or `"monthly"`.
#' @param route_id MBTA route ID (e.g. `"Red"`, `"Green-B"`).
#' @param base_url Base URL of the TransitMatters API.
#' @return A list of scheduled service records.
#' @export
#' @examples
#' \dontrun{
#' tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily", route_id = "Red")
#' }
tm_scheduled_service <- function(start_date, end_date, agg, route_id,
                                 base_url = tm_base_url()) {
  .tm_call("get_scheduled_service",
    start_date = .tm_date(start_date),
    end_date   = .tm_date(end_date),
    route_id   = route_id,
    agg        = agg,
    base_url   = base_url
  )
}

#' Get on-time performance for The RIDE or commuter rail
#'
#' Returns on-time performance counts summed over each day, week, or month.
#' The RIDE entries have `completed` and `onTime`, plus `requests`, `noShows`,
#' and `missed` where every day recorded them. Commuter rail entries have
#' `otpNumerator`, `otpDenominator`, `cancelled`, and the same counts split
#' into `peak` and `offPeak`.
#'
#' @param route_id `"RIDE"` for The RIDE, a commuter rail route ID (e.g.
#'   `"CR-Worcester"`), or `"commuter-rail"` for every commuter rail route
#'   combined.
#' @inheritParams tm_scheduled_service
#' @return A `data.frame` of reliability records.
#' @export
#' @examples
#' \dontrun{
#' tm_reliability("RIDE", "2025-01-01", "2025-03-31", agg = "monthly")
#' tm_reliability("CR-Worcester", "2025-03-01", "2025-03-31", agg = "weekly")
#' }
tm_reliability <- function(route_id, start_date, end_date, agg,
                           base_url = tm_base_url()) {
  .tm_data_frame(.tm_call("get_reliability",
    route_id   = route_id,
    start_date = .tm_date(start_date),
    end_date   = .tm_date(end_date),
    agg        = agg,
    base_url   = base_url,
    simplify   = TRUE
  ))
}

#' Get the slowest bus routes
#'
#' Ranks bus routes by average speed over a date range, slowest first. Speed
#' in mph is `miles_covered / (total_time / 3600)`.
#'
#' Data covers recent dates only. The API ranks routes over at most 150 days.
#'
#' @inheritParams tm_scheduled_service
#' @param limit Maximum number of routes to return, from 1 to 200. Optional;
#'   the API defaults to 10.
#' @return A `data.frame` with one row per route: `route`, trips delivered
#'   (`count`), `total_time` in seconds, `miles_covered`, and `n_traversals`.
#' @export
#' @examples
#' \dontrun{
#' tm_bus_speed_leaderboard("2026-09-01", "2026-09-30", limit = 20)
#' }
tm_bus_speed_leaderboard <- function(start_date, end_date, limit = NULL,
                                     base_url = tm_base_url()) {
  .tm_data_frame(.tm_call("get_bus_speed_leaderboard",
    start_date = .tm_date(start_date),
    end_date   = .tm_date(end_date),
    limit      = limit,
    base_url   = base_url,
    simplify   = TRUE
  ))
}

#' Get hourly weather in downtown Boston
#'
#' Data covers recent dates only.
#'
#' @inheritParams tm_scheduled_service
#' @return A `data.frame` with one row per hour: `timestamp` (Eastern local
#'   time, e.g. `"2026-04-22T14:00"`), `temperature_f`, `weather_code` (a WMO
#'   code), `condition` (e.g. `"clear"`, `"rain"`), `precipitation_in`,
#'   `humidity_pct`, and `wind_mph`.
#' @export
#' @examples
#' \dontrun{
#' tm_weather("2026-10-01", "2026-10-07")
#' }
tm_weather <- function(start_date, end_date, base_url = tm_base_url()) {
  .tm_data_frame(.tm_call("get_weather",
    start_date = .tm_date(start_date),
    end_date   = .tm_date(end_date),
    base_url   = base_url,
    simplify   = TRUE
  ))
}
