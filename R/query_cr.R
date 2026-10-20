TmCRQuery <- R6Class("TmCRQuery",
  inherit = TmBaseQuery,
  cloneable = FALSE,
  private = list(
    .route      = NULL,
    .route_data = NULL,
    .stop_data  = NULL,
    .from_data  = NULL,
    .to_data    = NULL,
    .direction  = NULL,

    .stop_ids = function(station, dir_key) {
      as.character(unlist(station$stops[[dir_key]]))
    },

    .resolve_stop_ids = function(station) {
      if (!is.null(private$.direction)) {
        private$.stop_ids(station, private$.direction)
      } else {
        unique(unlist(lapply(
          names(private$.route_data$direction),
          function(d) private$.stop_ids(station, d)
        )))
      }
    },

    # Validates a station name, warns if it is a terminus, and returns its data.
    .find_station_with_terminus_check = function(name, label = "station") {
      station <- .tm_find_station(private$.route_data, name)
      if (isTRUE(station$terminus)) {
        warning(
          "'", station$stop_name, "' is a terminus on ", private$.route,
          " -- stop IDs may be missing in one direction and headway/dwell ",
          "data may be incomplete.",
          call. = FALSE
        )
      }
      station
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
    #' Create a commuter rail query for the given route.
    #' @param route CR route ID, e.g. `"CR-Fairmount"`, `"CR-Lowell"`. Use
    #'   [tm_cr_routes()] to see all valid IDs.
    #' @param base_url API base URL.
    initialize = function(route, base_url = tm_base_url()) {
      super$initialize(base_url)
      normalized           <- .tm_normalize_route(route, .tm_cr_stations,
                                                  "commuter rail", "tm_cr_routes")
      private$.route       <- normalized
      private$.route_data  <- .tm_cr_stations[[normalized]]
    },

    #' @description Set the station for stop-level queries.
    #'   Issues a warning if the station is a terminus (data may be incomplete
    #'   in one direction).
    #' @param name Station name (case-insensitive). Use `$stations()` to browse.
    #' @return `self` (invisibly), for chaining.
    stop = function(name) {
      private$.stop_data <- private$.find_station_with_terminus_check(name)
      invisible(self)
    },

    #' @description Set the origin station for travel-time queries.
    #'   Issues a warning if the station is a terminus.
    #' @param name Station name (case-insensitive).
    #' @return `self` (invisibly), for chaining.
    from_stop = function(name) {
      private$.from_data <- private$.find_station_with_terminus_check(name)
      invisible(self)
    },

    #' @description Set the destination station for travel-time queries.
    #'   Issues a warning if the station is a terminus.
    #' @param name Station name (case-insensitive).
    #' @return `self` (invisibly), for chaining.
    to_stop = function(name) {
      private$.to_data <- private$.find_station_with_terminus_check(name)
      invisible(self)
    },

    #' @description Set the direction of travel.
    #' @param dir `"inbound"`, `"outbound"`, `0`, or `1`.
    #' @return `self` (invisibly), for chaining.
    direction = function(dir) {
      private$.direction <- .tm_resolve_direction(private$.route_data$direction, dir)
      invisible(self)
    },

    #' @description List all stations on this route.
    #' @return A `data.frame` with columns `stop_name`, `station`, `order`,
    #'   and `terminus`.
    stations = function() {
      stns <- private$.route_data$stations
      data.frame(
        stop_name = vapply(stns, `[[`, character(1), "stop_name"),
        station   = vapply(stns, `[[`, character(1), "station"),
        order     = vapply(stns, function(s) as.integer(s$order), integer(1)),
        terminus  = vapply(stns, function(s) isTRUE(s$terminus), logical(1)),
        stringsAsFactors = FALSE
      )
    },

    #' @description Fetch headway data. Requires `$stop()` and a date.
    #' @param date Optional `Date` or `"YYYY-MM-DD"` string (overrides `$date()`).
    #' @return A `data.frame` of headway event records.
    headways = function(date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      private$.assert_date("$headways()")
      private$.assert_stop("$headways()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get("get_headways", user_date = private$.date, stop = stop_ids)
    },

    #' @description Fetch dwell-time data. Requires `$stop()` and a date.
    #' @param date Optional `Date` or `"YYYY-MM-DD"` string.
    #' @return A `data.frame` of dwell event records.
    dwells = function(date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      private$.assert_date("$dwells()")
      private$.assert_stop("$dwells()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get("get_dwells", user_date = private$.date, stop = stop_ids)
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
      private$.get("get_travel_times", user_date = private$.date,
                   from_stop = from_ids, to_stop = to_ids)
    },

    #' @description Fetch aggregate headway data over a date range.
    #'   Requires `$stop()` and `$date_range()`.
    #' @return A `data.frame` of aggregated headway records.
    aggregate_headways = function() {
      private$.assert_date_range("$aggregate_headways()")
      private$.assert_stop("$aggregate_headways()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get("get_aggregate_headways",
        start_date = private$.start_date,
        end_date   = private$.end_date,
        stop       = stop_ids
      )
    },

    #' @description Fetch aggregate dwell-time data over a date range.
    #'   Requires `$stop()` and `$date_range()`.
    #' @return A `data.frame` of aggregated dwell records.
    aggregate_dwells = function() {
      private$.assert_date_range("$aggregate_dwells()")
      private$.assert_stop("$aggregate_dwells()")
      stop_ids <- private$.resolve_stop_ids(private$.stop_data)
      private$.get("get_aggregate_dwells",
        start_date = private$.start_date,
        end_date   = private$.end_date,
        stop       = stop_ids
      )
    },

    #' @description Fetch aggregate travel-time data over a date range.
    #'   Requires `$from_stop()`, `$to_stop()`, and `$date_range()`. Uses GTFS
    #'   place IDs; direction is not needed.
    #' @return A `data.frame` of aggregated travel-time records.
    aggregate_travel_times = function() {
      private$.assert_date_range("$aggregate_travel_times()")
      private$.assert_from_to("$aggregate_travel_times()")
      private$.get("get_aggregate_travel_times",
        start_date = private$.start_date,
        end_date   = private$.end_date,
        from_stop  = private$.from_data$station,
        to_stop    = private$.to_data$station
      )
    },

    #' @description Fetch aggregate travel-time data over a date range, by
    #'   date and by time of day. Requires `$from_stop()`, `$to_stop()`, and
    #'   `$date_range()`. Uses GTFS place IDs; direction is not needed.
    #' @return A list of two `data.frame`s: `by_date`, one row per service
    #'   day, and `by_time`, one row per 30-minute departure slot.
    aggregate_travel_times_v2 = function() {
      private$.assert_date_range("$aggregate_travel_times_v2()")
      private$.assert_from_to("$aggregate_travel_times_v2()")
      .tm_by_date_and_time(.tm_call("get_aggregate_travel_times_v2",
        start_date = private$.start_date,
        end_date   = private$.end_date,
        from_stop  = private$.from_data$station,
        to_stop    = private$.to_data$station,
        base_url   = private$.base_url,
        simplify   = TRUE
      ))
    },

    #' @description Fetch fleet metrics for this route over a date range:
    #'   trips with a known cab car (`fleet_trips`), the share of trips run
    #'   by each fleet type (`fleet_mix_<type>`), and the average cab car age
    #'   when known. Requires `$date_range()`.
    #' @param agg Aggregation level: `"daily"`, `"weekly"`, or `"monthly"`.
    #'   Optional; the API defaults to `"daily"`.
    #' @return A `data.frame` of trip metric records.
    trip_metrics = function(agg = NULL) {
      private$.assert_date_range("$trip_metrics()")
      private$.get("get_commuter_rail_trip_metrics",
        start_date = private$.start_date,
        end_date   = private$.end_date,
        route      = private$.route,
        agg        = agg
      )
    },

    #' @description Fetch on-time performance counts for this route over a
    #'   date range. Requires `$date_range()`. For The RIDE or all commuter
    #'   rail combined, use [tm_reliability()].
    #' @param agg Aggregation level: `"daily"`, `"weekly"`, or `"monthly"`.
    #' @return A `data.frame` of reliability records.
    reliability = function(agg) {
      private$.assert_date_range("$reliability()")
      tm_reliability(private$.route, private$.start_date, private$.end_date,
                     agg, base_url = private$.base_url)
    },

    #' @description Measure this route's schedule against Regional Rail
    #'   standards over a date range. Requires `$date_range()`.
    #' @param agg Aggregation level: `"daily"`, `"weekly"`, or `"monthly"`.
    #' @param day_kind Which schedule to measure: `"weekday"`, `"saturday"`,
    #'   `"sunday"`, or `"all"` (the default) to mix every day.
    #' @return A `data.frame` of scorecard records.
    scorecard = function(agg, day_kind = "all") {
      private$.assert_date_range("$scorecard()")
      private$.get("get_commuter_rail_scorecard",
        route_id   = private$.route,
        start_date = private$.start_date,
        end_date   = private$.end_date,
        agg        = agg,
        day_kind   = day_kind
      )
    }
  )
)

#' Create a commuter rail query
#'
#' Constructs a `TmCRQuery` object for the given MBTA commuter rail route.
#' Calling `$stop()` on a terminus station will issue a warning because stop IDs
#' are often missing in one direction at termini, making headway/dwell data
#' potentially incomplete.
#'
#' @param route CR route ID, e.g. `"CR-Fairmount"`, `"CR-Lowell"`. Use
#'   [tm_cr_routes()] to see all valid route IDs.
#' @param base_url API base URL. Defaults to the production host or the
#'   `tm_dashboard_base_url` option.
#' @return A `TmCRQuery` R6 object.
#' @export
#' @examples
#' \dontrun{
#' tm_cr_query("CR-Fairmount")$stop("Fairmount")$headways("2024-01-15")
#'
#' # Terminus warning is emitted here:
#' tm_cr_query("CR-Fitchburg")$stop("Wachusett")$headways("2024-01-15")
#' }
tm_cr_query <- function(route, base_url = tm_base_url()) {
  TmCRQuery$new(route, base_url)
}

#' List all available commuter rail routes
#'
#' @return A sorted character vector of CR route IDs.
#' @export
#' @examples
#' tm_cr_routes()
tm_cr_routes <- function() {
  sort(names(.tm_cr_stations))
}
