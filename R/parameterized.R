#' Get delay data by line
#'
#' Returns alert-based delay summaries for an MBTA line over a date range.
#'
#' @param start_date Start of the date range. A `Date` object or `"YYYY-MM-DD"`
#'   string.
#' @param end_date End of the date range. A `Date` object or `"YYYY-MM-DD"`
#'   string.
#' @param line MBTA line identifier, e.g. `"line-red"`.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list of line delay records.
#' @export
#' @examples
#' \dontrun{
#' tm_line_delays("2024-01-01", "2024-01-31", line = "line-red")
#' }
tm_line_delays <- function(start_date, end_date, line, base_url = tm_base_url()) {
  tm_request(
    "api/linedelays",
    query = list(
      start_date = .tm_date(start_date),
      end_date   = .tm_date(end_date),
      line       = .tm_line_color(line)
    ),
    base_url = base_url
  )
}

#' Get trip metrics by line
#'
#' Returns per-trip performance metrics aggregated over a date range.
#'
#' @inheritParams tm_line_delays
#' @param agg Aggregation level, e.g. `"daily"` or `"weekly"`.
#' @return A list of trip metric records.
#' @export
#' @examples
#' \dontrun{
#' tm_trip_metrics("2024-01-01", "2024-01-31", agg = "daily", line = "line-red")
#' }
tm_trip_metrics <- function(start_date, end_date, agg, line, base_url = tm_base_url()) {
  tm_request(
    "api/tripmetrics",
    query = list(
      start_date = .tm_date(start_date),
      end_date   = .tm_date(end_date),
      agg        = agg,
      line       = tolower(line)
    ),
    base_url = base_url
  )
}

#' Get scheduled service data
#'
#' Returns scheduled service counts aggregated over a date range for a single
#' MBTA route.
#'
#' @inheritParams tm_line_delays
#' @param agg Aggregation level, e.g. `"daily"` or `"weekly"`.
#' @param route_id MBTA route ID, e.g. `"Red"`, `"Orange"`, `"Green-B"`.
#' @return A list of scheduled service records.
#' @export
#' @examples
#' \dontrun{
#' tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily",
#'                      route_id = "Red")
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

#' Get ridership data
#'
#' Returns ridership counts over a date range, optionally filtered to a single
#' MBTA line.
#'
#' @inheritParams tm_line_delays
#' @param line_id Optional MBTA line identifier, e.g. `"line-red"`.
#' @return A list of ridership records.
#' @export
#' @examples
#' \dontrun{
#' tm_ridership("2024-01-01", "2024-01-31")
#' tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red")
#' }
tm_ridership <- function(start_date, end_date, line_id = NULL,
                         base_url = tm_base_url()) {
  tm_request(
    "api/ridership",
    query = list(
      start_date = .tm_date(start_date),
      end_date   = .tm_date(end_date),
      line_id    = if (!is.null(line_id)) .tm_gtfs_line_id(line_id)
    ),
    base_url = base_url
  )
}

#' Get slow zone / speed restriction data
#'
#' Returns current or historical speed restrictions for an MBTA line on a given
#' date.
#'
#' @param line_id MBTA line identifier, e.g. `"line-red"`.
#' @param on_date The date to query. A `Date` object or `"YYYY-MM-DD"` string.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list of speed restriction records.
#' @export
#' @examples
#' \dontrun{
#' tm_speed_restrictions("line-red", "2024-01-15")
#' }
tm_speed_restrictions <- function(line_id, on_date, base_url = tm_base_url()) {
  tm_request(
    "api/speed_restrictions",
    query = list(
      line_id = .tm_gtfs_line_id(line_id),
      date    = .tm_date(on_date)
    ),
    base_url = base_url
  )
}

#' Get service hours data
#'
#' Returns scheduled vs. delivered service hours aggregated over a date range
#' for a single MBTA line.
#'
#' @param start_date Start of the date range. A `Date` object or `"YYYY-MM-DD"`
#'   string.
#' @param end_date End of the date range. A `Date` object or `"YYYY-MM-DD"`
#'   string.
#' @param agg Aggregation level, e.g. `"daily"` or `"weekly"`.
#' @param line_id MBTA line identifier, e.g. `"line-red"`.
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list of service hours records.
#' @export
#' @examples
#' \dontrun{
#' tm_service_hours("2024-01-01", "2024-01-31", agg = "daily",
#'                  line_id = "line-red")
#' }
tm_service_hours <- function(start_date, end_date, agg, line_id = NULL,
                             base_url = tm_base_url()) {
  tm_request(
    "api/service_hours",
    query = list(
      start_date = .tm_date(start_date),
      end_date   = .tm_date(end_date),
      agg        = agg,
      line_id    = if (!is.null(line_id)) tolower(.tm_gtfs_line_id(line_id))
    ),
    base_url = base_url
  )
}
