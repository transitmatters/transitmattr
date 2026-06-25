TmBusQuery <- R6Class("TmBusQuery",
  inherit = TmBaseQuery,
  cloneable = FALSE,
  private = list(
    .route     = NULL,  # normalized route ID, e.g. "1"
    .route_data = NULL, # raw station list for this route
    .stop_data  = NULL, # station object for $stop()
    .direction  = NULL, # "0" or "1"

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

    .assert_stop = function(method) {
      if (is.null(private$.stop_data))
        stop(method, " requires a stop -- call $stop() first.", call. = FALSE)
    },
    .assert_direction = function(method) {
      if (is.null(private$.direction))
        stop(method, " requires a direction -- call $direction() first.", call. = FALSE)
    }
  ),
  public = list(
    #' @description
    #' Create a bus query for the given route.
    #' @param route Bus route ID, e.g. `"1"`, `"66"`, `"SL1"`. Use
    #'   [tm_bus_routes()] to see all valid IDs.
    #' @param base_url API base URL.
    initialize = function(route, base_url = tm_base_url()) {
      super$initialize(base_url)
      normalized           <- .tm_normalize_route(route, .tm_bus_stations,
                                                  "bus", "tm_bus_routes")
      private$.route       <- normalized
      private$.route_data  <- .tm_bus_stations[[normalized]]
    },

    #' @description Set the stop for stop-level queries.
    #' @param name Stop name (case-insensitive). Use `$stations()` to browse.
    #' @return `self` (invisibly), for chaining.
    stop = function(name) {
      private$.stop_data <- .tm_find_station(private$.route_data, name)
      invisible(self)
    },

    #' @description Set the direction of travel.
    #' @param dir `"inbound"`, `"outbound"`, `0`, or `1`.
    #' @return `self` (invisibly), for chaining.
    direction = function(dir) {
      private$.direction <- .tm_resolve_direction(private$.route_data$direction, dir)
      invisible(self)
    },

    #' @description List all stops on this route.
    #' @return A `data.frame` with columns `stop_name`, `station`, and `order`.
    stations = function() {
      stns <- private$.route_data$stations
      data.frame(
        stop_name = vapply(stns, `[[`, character(1), "stop_name"),
        station   = vapply(stns, `[[`, character(1), "station"),
        order     = vapply(stns, function(s) as.integer(s$order), integer(1)),
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
    }
  )
)

#' Create a bus query
#'
#' Constructs a `TmBusQuery` object for the given MBTA bus route.
#'
#' @param route Bus route ID, e.g. `"1"`, `"66"`, `"CT2"`, `"SL1"`. Use
#'   [tm_bus_routes()] to see all valid route IDs.
#' @param base_url API base URL. Defaults to the production host or the
#'   `tm_dashboard_base_url` option.
#' @return A `TmBusQuery` R6 object.
#' @export
#' @examples
#' \dontrun{
#' tm_bus_query("1")$stop("Harvard")$headways("2024-01-15")
#' tm_bus_query("66")$stop("Harvard")$direction("inbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
#' }
tm_bus_query <- function(route, base_url = tm_base_url()) {
  TmBusQuery$new(route, base_url)
}

#' List all available bus routes
#'
#' @return A sorted character vector of bus route IDs.
#' @export
#' @examples
#' tm_bus_routes()
tm_bus_routes <- function() {
  sort(names(.tm_bus_stations))
}
