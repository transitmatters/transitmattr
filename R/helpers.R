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

# An empty JSON array parses to an empty list; return a data.frame either way.
#' @noRd
.tm_data_frame <- function(result) {
  if (is.data.frame(result)) result else data.frame()
}

# Row-bind parsed per-request results into one data.frame. Results can lack
# optional columns, which become NA; empty results (`[]`) are skipped.
#' @noRd
.tm_bind_rows <- function(parts) {
  parts <- Filter(function(part) is.data.frame(part) && nrow(part) > 0, parts)
  if (!length(parts)) return(data.frame())
  if (length(parts) == 1) return(parts[[1]])
  columns <- unique(unlist(lapply(parts, names)))
  parts <- lapply(parts, function(part) {
    for (column in setdiff(columns, names(part))) part[[column]] <- NA
    part[columns]
  })
  result <- do.call(rbind, parts)
  rownames(result) <- NULL
  result
}

# Every date from `start` through `end`, as "YYYY-MM-DD" strings.
#' @noRd
.tm_days <- function(start, end) {
  start <- as.Date(.tm_date(start))
  end <- as.Date(.tm_date(end))
  if (end < start) {
    stop("The end date ", end, " is before the start date ", start, ".",
         call. = FALSE)
  }
  format(seq(start, end, by = "day"))
}

# Trip metrics endpoints refuse ranges of more than about 150 entries
# (upstream server/chalicelib/speed.py), so longer ranges are split.
.tm_max_span_days <- c(daily = 150, weekly = 7 * 150, monthly = 30 * 150)

# Split `start` through `end` into contiguous spans the API accepts for
# `agg`, as a list of c(start, end) Dates. Spans break at the start of a
# period (a Monday for "weekly", the 1st for "monthly"), since the API
# totals each period from the days it was asked for.
#' @noRd
.tm_spans <- function(start, end, agg) {
  start <- as.Date(.tm_date(start))
  end <- as.Date(.tm_date(end))
  # Let the API report a backwards range or an unknown agg.
  if (end < start || !agg %in% names(.tm_max_span_days)) {
    return(list(c(start, end)))
  }
  spans <- list()
  from <- start
  while (from <= end) {
    to <- min(from + .tm_max_span_days[[agg]] - 1, end)
    if (to < end) to <- .tm_period_start(to + 1, agg) - 1
    spans[[length(spans) + 1]] <- c(from, to)
    from <- to + 1
  }
  spans
}

#' @noRd
.tm_period_start <- function(date, agg) {
  switch(agg,
    daily   = date,
    weekly  = date - (as.integer(format(date, "%u")) - 1),
    monthly = as.Date(format(date, "%Y-%m-01"))
  )
}

# The aggregate travel times v2 response: by_date and by_time as data.frames.
#' @noRd
.tm_by_date_and_time <- function(result) {
  list(
    by_date = .tm_data_frame(result$by_date),
    by_time = .tm_data_frame(result$by_time)
  )
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
