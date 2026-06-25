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
    #'   Requires `$stop()` and `$date_range()`.
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
    #'   Requires `$from_stop()`, `$to_stop()`, and `$date_range()`. Uses GTFS
    #'   place IDs; direction is not needed.
    #' @return A `data.frame` of aggregated travel-time records.
    aggregate_travel_times = function() {
      private$.assert_date_range("$aggregate_travel_times()")
      private$.assert_from_to("$aggregate_travel_times()")
      result <- tm_request("api/aggregate/traveltimes", query = list(
        from_stop  = private$.from_data$station,
        to_stop    = private$.to_data$station,
        start_date = private$.start_date,
        end_date   = private$.end_date
      ), base_url = private$.base_url, simplify = TRUE)
      if (is.data.frame(result$data)) result$data else data.frame()
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
