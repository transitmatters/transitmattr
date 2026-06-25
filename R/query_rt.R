TmRTQuery <- R6Class("TmRTQuery",
  inherit = TmBaseQuery,
  cloneable = FALSE,
  private = list(
    .line      = NULL,  # normalized line name, e.g. "Red"
    .line_data = NULL,  # raw station list for this line
    .stop_data = NULL,  # station object for $stop()
    .from_data = NULL,  # station object for $from_stop()
    .to_data   = NULL,  # station object for $to_stop()
    .direction = NULL,  # "0" or "1"

    .stop_ids = function(station, dir_key) {
      as.character(unlist(station$stops[[dir_key]]))
    },

    # When direction is unset, collect IDs for all directions (deduped).
    .resolve_stop_ids = function(station) {
      if (!is.null(private$.direction)) {
        private$.stop_ids(station, private$.direction)
      } else {
        unique(unlist(lapply(
          names(private$.line_data$direction),
          function(d) private$.stop_ids(station, d)
        )))
      }
    },

    .assert_stop = function(method) {
      if (is.null(private$.stop_data))
        stop(method, " requires a stop -- call $stop() first.", call. = FALSE)
    },
    .assert_from_to = function(method) {
      if (is.null(private$.from_data) || is.null(private$.to_data))
        stop(method, " requires from/to stops -- call $from_stop() and $to_stop() first.",
             call. = FALSE)
    },
    .assert_direction = function(method) {
      if (is.null(private$.direction))
        stop(method, " requires a direction -- call $direction() first.", call. = FALSE)
    }
  ),
  public = list(
    #' @description
    #' Create a rapid transit query for the given line.
    #' @param line Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or
    #'   `"Mattapan"`. Case-insensitive; `"line-red"` prefix also accepted.
    #' @param base_url API base URL.
    initialize = function(line, base_url = tm_base_url()) {
      super$initialize(base_url)
      normalized          <- .tm_normalize_line(line)
      private$.line       <- normalized
      private$.line_data  <- .tm_rt_stations[[normalized]]
    },

    #' @description
    #' Set the station for stop-level queries (headways, dwells).
    #' @param name Station name (case-insensitive). Use `$stations()` to browse.
    #' @return `self` (invisibly), for chaining.
    stop = function(name) {
      private$.stop_data <- .tm_find_station(private$.line_data, name)
      invisible(self)
    },

    #' @description Set the origin station for travel-time queries.
    #' @param name Station name (case-insensitive).
    #' @return `self` (invisibly), for chaining.
    from_stop = function(name) {
      private$.from_data <- .tm_find_station(private$.line_data, name)
      invisible(self)
    },

    #' @description Set the destination station for travel-time queries.
    #' @param name Station name (case-insensitive).
    #' @return `self` (invisibly), for chaining.
    to_stop = function(name) {
      private$.to_data <- .tm_find_station(private$.line_data, name)
      invisible(self)
    },

    #' @description Set the direction of travel.
    #' @param dir Direction name (`"northbound"`, `"southbound"`, `"eastbound"`,
    #'   `"westbound"`) or numeric code `0` / `1`. Use `$directions()` to see
    #'   which names apply.
    #' @return `self` (invisibly), for chaining.
    direction = function(dir) {
      private$.direction <- .tm_resolve_direction(private$.line_data$direction, dir)
      invisible(self)
    },

    #' @description List all stations on this line.
    #' @return A `data.frame` with columns `stop_name`, `station`, `order`,
    #'   and `branches`.
    stations = function() {
      stns <- private$.line_data$stations
      data.frame(
        stop_name = vapply(stns, `[[`, character(1), "stop_name"),
        station   = vapply(stns, `[[`, character(1), "station"),
        order     = vapply(stns, function(s) as.integer(s$order), integer(1)),
        branches  = vapply(stns, function(s) {
          b <- s$branches
          if (is.null(b) || !length(b)) NA_character_
          else paste(unlist(b), collapse = ", ")
        }, character(1)),
        stringsAsFactors = FALSE
      )
    },

    #' @description Get direction labels for this line.
    #' @return A named character vector, e.g. `c("0" = "northbound", "1" = "southbound")`.
    directions = function() {
      dirs <- private$.line_data$direction
      setNames(unlist(dirs), names(dirs))
    },

    #' @description Fetch headway data. Requires `$stop()` and either `$date()`
    #'   or a `date` argument here.
    #' @param date Optional `Date` or `"YYYY-MM-DD"` string (overrides `$date()`).
    #' @return A `data.frame` of headway event records.
    headways = function(date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      private$.assert_date("$headways()")
      private$.assert_stop("$headways()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get(c("api", "headways", private$.date), list(stop = stop_ids))
    },

    #' @description Fetch dwell-time data. Requires `$stop()` and a date.
    #' @param date Optional `Date` or `"YYYY-MM-DD"` string.
    #' @return A `data.frame` of dwell event records.
    dwells = function(date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      private$.assert_date("$dwells()")
      private$.assert_stop("$dwells()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get(c("api", "dwells", private$.date), list(stop = stop_ids))
    },

    #' @description Fetch travel-time data. Requires `$from_stop()`, `$to_stop()`,
    #'   `$direction()`, and a date.
    #' @param date Optional `Date` or `"YYYY-MM-DD"` string.
    #' @return A `data.frame` of travel-time event records.
    travel_times = function(date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      private$.assert_date("$travel_times()")
      private$.assert_from_to("$travel_times()")
      private$.assert_direction("$travel_times()")
      from_ids <- private$.stop_ids(private$.from_data, private$.direction)
      to_ids   <- private$.stop_ids(private$.to_data,   private$.direction)
      private$.get(
        c("api", "traveltimes", private$.date),
        list(from_stop = from_ids, to_stop = to_ids)
      )
    },

    #' @description Fetch aggregate headway data over a date range.
    #'   Requires `$stop()` and `$date_range()`. If `$direction()` is set, only
    #'   that direction's stop IDs are sent; otherwise all stop IDs for the
    #'   station are sent.
    #' @return A `data.frame` of aggregated headway records.
    aggregate_headways = function() {
      private$.assert_date_range("$aggregate_headways()")
      private$.assert_stop("$aggregate_headways()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get("api/aggregate/headways", list(
        stop       = stop_ids,
        start_date = private$.start_date,
        end_date   = private$.end_date
      ))
    },

    #' @description Fetch aggregate dwell-time data over a date range.
    #'   Requires `$stop()` and `$date_range()`.
    #' @return A `data.frame` of aggregated dwell records.
    aggregate_dwells = function() {
      private$.assert_date_range("$aggregate_dwells()")
      private$.assert_stop("$aggregate_dwells()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get("api/aggregate/dwells", list(
        stop       = stop_ids,
        start_date = private$.start_date,
        end_date   = private$.end_date
      ))
    },

    #' @description Fetch aggregate travel-time data over a date range.
    #'   Requires `$from_stop()`, `$to_stop()`, and `$date_range()`. Direction
    #'   is inferred from station order when not set via `$direction()`.
    #' @return A `data.frame` of aggregated travel-time records.
    aggregate_travel_times = function() {
      private$.assert_date_range("$aggregate_travel_times()")
      private$.assert_from_to("$aggregate_travel_times()")
      dir <- if (!is.null(private$.direction)) {
        private$.direction
      } else if (private$.from_data$order > private$.to_data$order) {
        "0"
      } else {
        "1"
      }
      from_ids <- private$.stop_ids(private$.from_data, dir)
      to_ids   <- private$.stop_ids(private$.to_data,   dir)
      private$.get("api/aggregate/traveltimes", list(
        from_stop  = from_ids,
        to_stop    = to_ids,
        start_date = private$.start_date,
        end_date   = private$.end_date
      ))
    },

    #' @description Fetch line delay summaries over a date range.
    #'   Requires `$date_range()`.
    #' @param agg Aggregation level: `"daily"` or `"weekly"`. Optional.
    #' @return A `data.frame` of delay records.
    line_delays = function(agg = NULL) {
      private$.assert_date_range("$line_delays()")
      private$.get("api/linedelays", list(
        start_date = private$.start_date,
        end_date   = private$.end_date,
        line       = .tm_line_color(private$.line),
        agg        = agg
      ))
    },

    #' @description Fetch per-trip performance metrics over a date range.
    #'   Requires `$date_range()`.
    #' @param agg Aggregation level: `"daily"` or `"weekly"`.
    #' @return A `data.frame` of trip metric records.
    trip_metrics = function(agg) {
      private$.assert_date_range("$trip_metrics()")
      private$.get("api/tripmetrics", list(
        start_date = private$.start_date,
        end_date   = private$.end_date,
        agg        = agg,
        line       = tolower(.tm_gtfs_line_id(private$.line))
      ))
    },

    #' @description Fetch speed restriction / slow zone data.
    #'   Requires a date (via `$date()` or the `date` argument).
    #' @param date Optional `Date` or `"YYYY-MM-DD"` string.
    #' @return A list with `available`, `date`, and `zones` fields.
    speed_restrictions = function(date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      private$.assert_date("$speed_restrictions()")
      tm_request("api/speed_restrictions", query = list(
        line_id = .tm_gtfs_line_id(private$.line),
        date    = private$.date
      ), base_url = private$.base_url)
    },

    #' @description Fetch ridership counts over a date range.
    #'   Requires `$date_range()`.
    #' @return A `data.frame` of ridership records.
    ridership = function() {
      private$.assert_date_range("$ridership()")
      private$.get("api/ridership", list(
        start_date = private$.start_date,
        end_date   = private$.end_date,
        line_id    = .tm_gtfs_line_id(private$.line)
      ))
    },

    #' @description Fetch scheduled vs. delivered service hours over a date range.
    #'   Requires `$date_range()`.
    #' @param agg Aggregation level: `"daily"` or `"weekly"`.
    #' @return A `data.frame` of service hours records.
    service_hours = function(agg) {
      private$.assert_date_range("$service_hours()")
      private$.get("api/service_hours", list(
        start_date = private$.start_date,
        end_date   = private$.end_date,
        agg        = agg,
        line_id    = tolower(.tm_gtfs_line_id(private$.line))
      ))
    },

    #' @description Fetch scheduled service counts over a date range.
    #'   Requires `$date_range()`.
    #' @param agg Aggregation level: `"daily"` or `"weekly"`.
    #' @return A `data.frame` of scheduled service records.
    scheduled_service = function(agg) {
      private$.assert_date_range("$scheduled_service()")
      private$.get("api/scheduledservice", list(
        start_date = private$.start_date,
        end_date   = private$.end_date,
        agg        = agg,
        route_id   = private$.line
      ))
    }
  )
)

#' Create a rapid transit query
#'
#' Constructs a `TmRTQuery` object for the given MBTA rapid transit line.
#' Chain builder methods to set context, then call a terminal method to fetch
#' data.
#'
#' @param line Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or
#'   `"Mattapan"`. Case-insensitive; `"line-red"` form also accepted.
#' @param base_url API base URL. Defaults to the production host or the
#'   `tm_dashboard_base_url` option.
#' @return A `TmRTQuery` R6 object.
#' @export
#' @examples
#' \dontrun{
#' # Headways at Harvard on the Red Line
#' tm_rt_query("Red")$stop("Harvard")$headways("2024-01-15")
#'
#' # Travel times (direction required for stop ID resolution)
#' tm_rt_query("Red")$from_stop("Alewife")$to_stop("Kendall/MIT")$direction("southbound")$travel_times("2024-01-15")
#'
#' # Line-level aggregate (no stop needed)
#' tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")
#' }
tm_rt_query <- function(line, base_url = tm_base_url()) {
  TmRTQuery$new(line, base_url)
}
