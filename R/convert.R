# Convert parsed API responses to R types: times to POSIXct in Eastern time,
# dates to Date, and so on. Column and field names stay as the API sends them.
#
# The API's spec doesn't say which strings are dates or times, so this table
# does. It maps each generated model (see R/generated-*.R) to the fields that
# need converting and their type:
#
#   "datetime"     a time, e.g. "2024-01-15T05:27:12" (Eastern wall-clock time)
#                  or "2024-01-15T05:58:00-05:00" (with a UTC offset)
#   "date"         "2024-01-15"
#   "time_of_day"  "1970-01-01T05:30:00", the time of day on a dummy date
#   "integer", "number", "character"
#   "<Model>"      a nested object or array of objects, converted with that
#                  model's entry
#   "map:<Model>"  an object whose values are each a <Model>
#
# test-convert.R checks every model and field named here exists, and keeps a
# snapshot of every response model's fields: when a spec sync changes them,
# decide whether the new fields need an entry here, then accept the snapshot.
.tm_conversions <- list(
  AggregateByDate              = c(service_date = "date"),
  AggregateByTime              = c(dep_time_from_epoch = "time_of_day"),
  Alert                        = c(valid_from = "datetime", valid_to = "datetime"),
  AlertActivePeriod            = c(start = "datetime", end = "datetime"),
  BusTripMetricsEntry          = c(date = "date"),
  ByDayKindServiceLevels       = c(date = "date"),
  CrScorecardEntry             = c(date = "date"),
  CrTripMetricsEntry           = c(date = "date"),
  DashboardLine                = c(startDate = "date"),
  DashboardSummary             = c(startDate = "date", endDate = "date"),
  DwellEvent                   = c(arr_dt = "datetime", dep_dt = "datetime"),
  FacilitiesResponse           = c(data = "Facility"),
  Facility                     = c(attributes = "FacilityAttributes"),
  FacilityAttributes           = c(latitude = "number", longitude = "number"),
  GetScheduledServiceResponse  = c(start_date = "date", end_date = "date",
                                   start_date_service_levels = "ServiceLevelsByDayKind",
                                   end_date_service_levels = "ServiceLevelsByDayKind",
                                   counts = "ScheduledServiceCount"),
  HeadwayAggregateByDate       = c(service_date = "date"),
  # The spec says direction is a string here, unlike the other events.
  HeadwayEvent                 = c(current_dep_dt = "datetime", direction = "integer"),
  LineDelayEntry               = c(date = "date"),
  # DELAY and DETOUR alerts send stop IDs as numbers.
  LiveAlert                    = c(active_period = "AlertActivePeriod",
                                   stops = "character"),
  ReliabilityEntry             = c(date = "date"),
  RidershipEntry               = c(date = "date"),
  ScheduledServiceCount        = c(date = "date"),
  ServiceHoursEntry            = c(date = "date"),
  ServiceLevelsByDayKind       = c(weekday = "ByDayKindServiceLevels",
                                   saturday = "ByDayKindServiceLevels",
                                   sunday = "ByDayKindServiceLevels"),
  ServiceRidershipDashboardResponse = c(summaryData = "DashboardSummary",
                                        modeData = "map:DashboardSummary",
                                        lineData = "map:DashboardLine"),
  SpeedRestrictionZone         = c(date = "date", reported = "date"),
  SpeedRestrictionsResponse    = c(date = "date", zones = "SpeedRestrictionZone"),
  StopsResponse                = c(service_start = "date", service_end = "date"),
  TimePredictionBucket         = c(weekly = "date"),
  TimePredictionWeek           = c(week = "date", prediction = "TimePredictionBucket"),
  TravelTimeAggregate2Response = c(by_date = "AggregateByDate",
                                   by_time = "AggregateByTime"),
  TravelTimeEvent              = c(dep_dt = "datetime", arr_dt = "datetime"),
  TripMetricsEntry             = c(date = "date"),
  WeatherHourlyEntry           = c(timestamp = "datetime")
)

.tm_tz <- "America/New_York"

# Convert `x`, a parsed response of type `model`. Handles data frames (from
# simplifyVector = TRUE), objects (named lists), and arrays (unnamed lists).
#' @noRd
.tm_convert <- function(x, model) {
  fields <- .tm_conversions[[model]]
  if (is.null(fields) || is.null(x)) return(x)
  if (!is.data.frame(x) && is.list(x) && is.null(names(x))) {
    return(lapply(x, .tm_convert, model = model))
  }
  for (field in intersect(names(fields), names(x))) {
    value <- .tm_convert_field(x[[field]], fields[[field]], model, field)
    # Assigning NULL with [[<- would drop the field.
    if (is.data.frame(x)) x[[field]] <- value else x[field] <- list(value)
  }
  x
}

#' @noRd
.tm_convert_field <- function(value, type, model, field) {
  if (is.null(value)) return(value)
  if (startsWith(type, "map:")) {
    return(lapply(value, .tm_convert, model = sub("^map:", "", type)))
  }
  if (!is.null(.tm_conversions[[type]])) return(.tm_convert(value, type))
  # An array of values: a list column, or a list without simplifyVector.
  if (is.list(value)) {
    return(lapply(value, .tm_convert_field, type = type, model = model,
                  field = field))
  }
  parsed <- .tm_parsers[[type]](value)
  failed <- is.na(parsed) & !is.na(value)
  if (any(failed)) {
    warning("Couldn't convert `", model, "$", field, "` to ", type, " (e.g. \"",
            value[failed][[1]], "\"), so it's left as the API sent it.",
            call. = FALSE)
    return(value)
  }
  parsed
}

.tm_parsers <- list(
  datetime    = function(x) .tm_as_datetime(x),
  date        = function(x) as.Date(as.character(x), format = "%Y-%m-%d"),
  time_of_day = function(x) .tm_as_time_of_day(x),
  integer     = function(x) suppressWarnings(as.integer(x)),
  number      = function(x) suppressWarnings(as.numeric(x)),
  character   = function(x) as.character(x)
)

# Times without a UTC offset are Eastern wall-clock times; times with one
# are converted to Eastern. Seconds are optional.
#' @noRd
.tm_as_datetime <- function(x) {
  x <- sub("T", " ", as.character(x), fixed = TRUE)
  seconds <- rep(NA_real_, length(x))
  offset <- grepl("[+-][0-9]{2}:?[0-9]{2}$", x)
  local <- !offset & !is.na(x)
  if (any(local)) {
    stamp <- x[local]
    # Weather timestamps have no seconds, e.g. "2026-10-01T14:00".
    no_seconds <- grepl(" [0-9]{2}:[0-9]{2}$", stamp)
    stamp[no_seconds] <- paste0(stamp[no_seconds], ":00")
    seconds[local] <- as.numeric(as.POSIXct(stamp, format = "%Y-%m-%d %H:%M:%OS",
                                            tz = .tm_tz))
  }
  if (any(offset)) {
    # strptime's %z wants "-0500", not "-05:00".
    stamp <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", x[offset])
    seconds[offset] <- as.numeric(strptime(stamp, "%Y-%m-%d %H:%M:%OS%z",
                                           tz = "UTC"))
  }
  .POSIXct(seconds, tz = .tm_tz)
}

# "1970-01-01T05:30:00" -> 05:30:00, ignoring the dummy date.
#' @noRd
.tm_as_time_of_day <- function(x) {
  hms::parse_hms(sub("^.*T", "", as.character(x)))
}

# The generated model that `operation` returns, read from the generated
# method, e.g. "HeadwayEvent" for get_headways.
.tm_response_models <- new.env(parent = emptyenv())

#' @noRd
.tm_response_model <- function(operation) {
  if (is.null(.tm_response_models[[operation]])) {
    method <- ApiApi$public_methods[[paste0(operation, "_with_http_info")]]
    code <- paste(deparse(body(method)), collapse = "\n")
    # deparse() may wrap the call onto a second line.
    type <- regmatches(code, regexpr('DeserializeResponse\\(local_var_resp,\\s*"[^"]+"', code))
    .tm_response_models[[operation]] <- sub('^.*"(array\\[)?(\\w+)\\]?"$', "\\2", type)
  }
  .tm_response_models[[operation]]
}
