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
.tm_find_station <- function(route_data, stop_name) {
  stations <- route_data$stations
  names_lc <- tolower(vapply(stations, `[[`, character(1), "stop_name"))
  idx <- which(names_lc == tolower(stop_name))
  if (length(idx) == 0) {
    stop(
      "Station '", stop_name, "' not found. ",
      "Use $stations() to see valid station names."
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
