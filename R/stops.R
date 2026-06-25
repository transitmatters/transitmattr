# Valid rapid transit line names (keys in .tm_rt_stations)
.tm_rt_lines <- c("Red", "Orange", "Blue", "Green", "Mattapan")

#' @noRd
.tm_normalize_line <- function(line) {
  color <- sub("^line-", "", tolower(line))
  canonical <- paste0(toupper(substr(color, 1, 1)), substr(color, 2, nchar(color)))
  if (!canonical %in% .tm_rt_lines) {
    stop(
      "Unknown line '", line, "'. ",
      "Valid lines: ", paste(.tm_rt_lines, collapse = ", "), "."
    )
  }
  canonical
}

#' @noRd
.tm_find_station <- function(line_data, stop_name) {
  stations <- line_data$stations
  names_lc <- tolower(vapply(stations, `[[`, character(1), "stop_name"))
  idx <- which(names_lc == tolower(stop_name))
  if (length(idx) == 0) {
    valid <- vapply(stations, `[[`, character(1), "stop_name")
    stop(
      "Station '", stop_name, "' not found. ",
      "Use tm_line_stations() to see valid station names."
    )
  }
  stations[[idx[1]]]
}

#' @noRd
.tm_resolve_direction <- function(dirs, direction) {
  if (is.numeric(direction) || direction %in% c("0", "1")) {
    key <- as.character(as.integer(direction))
    if (!key %in% names(dirs)) stop("Direction must be 0 or 1.")
    return(key)
  }
  keys <- names(dirs)[tolower(unlist(dirs)) == tolower(direction)]
  if (length(keys) == 0) {
    stop(
      "Unknown direction '", direction, "'. ",
      "Valid directions: ",
      paste(vapply(names(dirs), function(k) paste0('"', dirs[[k]], '"'), character(1)),
            collapse = ", "), "."
    )
  }
  keys[1]
}

#' Look up numeric stop IDs for a rapid transit station
#'
#' Returns the stop ID(s) used by the headway, dwell, and travel-time endpoints
#' for a given station and direction of travel.
#'
#' @param line Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or
#'   `"Mattapan"` (case-insensitive; `"line-red"` form also accepted).
#' @param stop_name Station name (case-insensitive), e.g. `"Alewife"`,
#'   `"Davis"`. Use [tm_line_stations()] to see all valid names.
#' @param direction Direction of travel. Either the direction name for the line
#'   (e.g. `"northbound"`, `"southbound"`, `"eastbound"`, `"westbound"`) or the
#'   numeric code `0` or `1`. Use [tm_line_directions()] to see which names
#'   apply to a given line.
#' @return A character vector of stop IDs (most stations have one; branching
#'   or multi-platform stations may have several).
#' @export
#' @examples
#' tm_stop_id("Red", "Alewife", "southbound")
#' tm_stop_id("Red", "Davis", 0)
#' tm_stop_id("Green", "Park Street", "eastbound")
tm_stop_id <- function(line, stop_name, direction) {
  line_key  <- .tm_normalize_line(line)
  line_data <- .tm_rt_stations[[line_key]]
  station   <- .tm_find_station(line_data, stop_name)
  dir_key   <- .tm_resolve_direction(line_data$direction, direction)
  as.character(unlist(station$stops[[dir_key]]))
}

#' Look up the GTFS place ID for a rapid transit station
#'
#' Returns the GTFS parent-station identifier (e.g. `"place-alfcl"`,
#' `"place-davis"`). These are provided for cross-referencing with the MBTA v3
#' API. The TransitMatters aggregate endpoints expect stop IDs from
#' [tm_stop_id()], not place IDs.
#'
#' @inheritParams tm_stop_id
#' @return A single GTFS place ID string.
#' @export
#' @examples
#' tm_place_id("Red", "Alewife")
#' tm_place_id("Green", "Park Street")
tm_place_id <- function(line, stop_name) {
  line_key  <- .tm_normalize_line(line)
  line_data <- .tm_rt_stations[[line_key]]
  station   <- .tm_find_station(line_data, stop_name)
  station$station
}

#' List all stations on a rapid transit line
#'
#' Returns a data frame of every station on the line, useful for discovering
#' valid station names to pass to [tm_stop_id()] and [tm_place_id()].
#'
#' @inheritParams tm_stop_id
#' @return A data frame with columns `stop_name`, `station` (GTFS place ID),
#'   `order`, and `branches`.
#' @export
#' @examples
#' tm_line_stations("Red")
#' tm_line_stations("Green")
tm_line_stations <- function(line) {
  line_key  <- .tm_normalize_line(line)
  line_data <- .tm_rt_stations[[line_key]]
  stations  <- line_data$stations
  data.frame(
    stop_name = vapply(stations, `[[`, character(1), "stop_name"),
    station   = vapply(stations, `[[`, character(1), "station"),
    order     = vapply(stations, function(s) as.integer(s$order), integer(1)),
    branches  = vapply(stations, function(s) {
      b <- s$branches
      if (is.null(b) || length(b) == 0) NA_character_
      else paste(unlist(b), collapse = ", ")
    }, character(1)),
    stringsAsFactors = FALSE
  )
}

#' Get direction names for a rapid transit line
#'
#' Returns the direction labels used by a line, which are the valid string
#' values for the `direction` argument of [tm_stop_id()].
#'
#' @inheritParams tm_stop_id
#' @return A named character vector, e.g.
#'   `c("0" = "northbound", "1" = "southbound")`.
#' @export
#' @examples
#' tm_line_directions("Red")
#' tm_line_directions("Green")
tm_line_directions <- function(line) {
  line_key  <- .tm_normalize_line(line)
  line_data <- .tm_rt_stations[[line_key]]
  dirs      <- line_data$direction
  setNames(unlist(dirs), names(dirs))
}

# -- Internal helpers for non-RT modes ----------------------------------------

#' @noRd
.tm_normalize_route <- function(route, stations_env, type_label, routes_fn) {
  keys    <- names(stations_env)
  matched <- keys[tolower(keys) == tolower(route)]
  if (length(matched) == 0) {
    stop(
      "Unknown ", type_label, " route '", route, "'. ",
      "Use ", routes_fn, "() to see valid route IDs."
    )
  }
  matched[1]
}

#' @noRd
.tm_stations_df <- function(route_data, include_terminus = FALSE) {
  stations <- route_data$stations
  df <- data.frame(
    stop_name = vapply(stations, `[[`, character(1), "stop_name"),
    station   = vapply(stations, `[[`, character(1), "station"),
    order     = vapply(stations, function(s) as.integer(s$order), integer(1)),
    stringsAsFactors = FALSE
  )
  if (include_terminus) {
    df$terminus <- vapply(stations, function(s) {
      isTRUE(s$terminus)
    }, logical(1))
  }
  df
}

# -- Bus -----------------------------------------------------------------------

#' Look up stop IDs for a bus route station
#'
#' @param route Bus route ID, e.g. `"1"`, `"66"`, `"CT2"`, `"SL1"`.
#'   Use [tm_bus_routes()] to see all valid route IDs.
#' @param stop_name Station name (case-insensitive). Use [tm_bus_stations()]
#'   to see valid names for a route.
#' @param direction `"outbound"`, `"inbound"`, `0`, or `1`.
#' @return A character vector of stop IDs.
#' @export
#' @examples
#' tm_bus_stop_id("1", "Harvard", "inbound")
#' tm_bus_stop_id("66", "Harvard", "outbound")
tm_bus_stop_id <- function(route, stop_name, direction) {
  key       <- .tm_normalize_route(route, .tm_bus_stations, "bus", "tm_bus_routes")
  rd        <- .tm_bus_stations[[key]]
  station   <- .tm_find_station(rd, stop_name)
  dir_key   <- .tm_resolve_direction(rd$direction, direction)
  as.character(unlist(station$stops[[dir_key]]))
}

#' List all stations on a bus route
#'
#' @param route Bus route ID. Use [tm_bus_routes()] to see all valid IDs.
#' @return A data frame with columns `stop_name`, `station`, and `order`.
#' @export
#' @examples
#' tm_bus_stations("1")
tm_bus_stations <- function(route) {
  key <- .tm_normalize_route(route, .tm_bus_stations, "bus", "tm_bus_routes")
  .tm_stations_df(.tm_bus_stations[[key]])
}

#' List all available bus routes
#'
#' @return A sorted character vector of bus route IDs available for stop lookup.
#' @export
#' @examples
#' tm_bus_routes()
tm_bus_routes <- function() {
  sort(names(.tm_bus_stations))
}

# -- Commuter Rail -------------------------------------------------------------

#' Look up stop IDs for a commuter rail station
#'
#' Terminus stations in one direction may return `character(0)` — this is
#' normal (the line only serves that stop in one direction).
#'
#' @param route CR route ID, e.g. `"CR-Fairmount"`, `"CR-Lowell"`.
#'   Use [tm_cr_routes()] to see all valid route IDs.
#' @param stop_name Station name (case-insensitive). Use [tm_cr_stations()]
#'   to see valid names for a route.
#' @param direction `"outbound"`, `"inbound"`, `0`, or `1`.
#' @return A character vector of stop IDs (may be empty at some termini).
#' @export
#' @examples
#' tm_cr_stop_id("CR-Fairmount", "Fairmount", "outbound")
#' tm_cr_stop_id("CR-Fairmount", "South Station", "inbound")
tm_cr_stop_id <- function(route, stop_name, direction) {
  key     <- .tm_normalize_route(route, .tm_cr_stations, "commuter rail",
                                 "tm_cr_routes")
  rd      <- .tm_cr_stations[[key]]
  station <- .tm_find_station(rd, stop_name)
  dir_key <- .tm_resolve_direction(rd$direction, direction)
  as.character(unlist(station$stops[[dir_key]]))
}

#' Look up the GTFS place ID for a commuter rail station
#'
#' Returns the GTFS parent-station identifier (e.g. `"place-sstat"`). These
#' are provided for cross-referencing with the MBTA v3 API. The TransitMatters
#' aggregate endpoints expect stop IDs from [tm_cr_stop_id()], not place IDs.
#'
#' @param route CR route ID. Use [tm_cr_routes()] to see all valid IDs.
#' @param stop_name Station name (case-insensitive).
#' @return A single GTFS place ID string (e.g. `"place-sstat"`).
#' @export
#' @examples
#' tm_cr_place_id("CR-Fairmount", "South Station")
#' tm_cr_place_id("CR-Fairmount", "Fairmount")
tm_cr_place_id <- function(route, stop_name) {
  key     <- .tm_normalize_route(route, .tm_cr_stations, "commuter rail",
                                 "tm_cr_routes")
  rd      <- .tm_cr_stations[[key]]
  station <- .tm_find_station(rd, stop_name)
  station$station
}

#' List all stations on a commuter rail line
#'
#' @param route CR route ID. Use [tm_cr_routes()] to see all valid IDs.
#' @return A data frame with columns `stop_name`, `station` (GTFS place ID),
#'   `order`, and `terminus`.
#' @export
#' @examples
#' tm_cr_stations("CR-Fairmount")
tm_cr_stations <- function(route) {
  key <- .tm_normalize_route(route, .tm_cr_stations, "commuter rail",
                              "tm_cr_routes")
  .tm_stations_df(.tm_cr_stations[[key]], include_terminus = TRUE)
}

#' List all available commuter rail routes
#'
#' @return A sorted character vector of CR route IDs available for stop lookup.
#' @export
#' @examples
#' tm_cr_routes()
tm_cr_routes <- function() {
  sort(names(.tm_cr_stations))
}

# -- Ferry ---------------------------------------------------------------------

#' Look up stop IDs for a ferry station
#'
#' @param route Ferry route ID, e.g. `"Boat-F1"`, `"Boat-F4"`.
#'   Use [tm_ferry_routes()] to see all valid route IDs.
#' @param stop_name Station name (case-insensitive). Use [tm_ferry_stations()]
#'   to see valid names for a route.
#' @param direction `"outbound"`, `"inbound"`, `0`, or `1`.
#' @return A character vector of stop IDs.
#' @export
#' @examples
#' tm_ferry_stop_id("Boat-F1", "Hingham", "inbound")
#' tm_ferry_stop_id("Boat-F1", "Long Wharf (North)", "outbound")
tm_ferry_stop_id <- function(route, stop_name, direction) {
  key     <- .tm_normalize_route(route, .tm_ferry_stations, "ferry",
                                 "tm_ferry_routes")
  rd      <- .tm_ferry_stations[[key]]
  station <- .tm_find_station(rd, stop_name)
  dir_key <- .tm_resolve_direction(rd$direction, direction)
  as.character(unlist(station$stops[[dir_key]]))
}

#' List all stations on a ferry route
#'
#' @param route Ferry route ID. Use [tm_ferry_routes()] to see all valid IDs.
#' @return A data frame with columns `stop_name`, `station`, `order`,
#'   and `terminus`.
#' @export
#' @examples
#' tm_ferry_stations("Boat-F1")
tm_ferry_stations <- function(route) {
  key <- .tm_normalize_route(route, .tm_ferry_stations, "ferry",
                              "tm_ferry_routes")
  .tm_stations_df(.tm_ferry_stations[[key]], include_terminus = TRUE)
}

#' List all available ferry routes
#'
#' @return A sorted character vector of ferry route IDs available for stop
#'   lookup.
#' @export
#' @examples
#' tm_ferry_routes()
tm_ferry_routes <- function() {
  sort(names(.tm_ferry_stations))
}
