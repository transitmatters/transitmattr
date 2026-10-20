## Record real API responses into tests/testthat/ for test-integration.R.
##
## Each entry in `calls` below makes the requests one integration test
## replays. httptest2 names each fixture after the request's URL and a hash of
## its query, so re-record whenever a request changes. Run from the package
## root:
##
##   Rscript data-raw/record_fixtures.R                     # every call
##   Rscript data-raw/record_fixtures.R weather reliability # just these
##
## Requires: devtools, httptest2

if (!file.exists("DESCRIPTION")) {
  stop("Run this script from the package root.", call. = FALSE)
}
devtools::load_all(quiet = TRUE)

calls <- list(
  routes = function() tm_routes(),
  stops = function() tm_stops("Red"),
  headways = function() {
    tm_rt_query("Red")$stop("Alewife")$headways("2024-01-15")
  },
  travel_times = function() {
    tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$
      direction("northbound")$travel_times("2024-01-15")
  },
  alerts = function() tm_alerts("2024-01-15", route = "Red"),
  ridership = function() {
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$ridership()
  },
  line_delays = function() {
    q <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")
    q$line_delays()
    q$line_delays("daily")
  },
  speed_restrictions = function() {
    tm_rt_query("Red")$speed_restrictions("2024-01-15")
  },
  trip_metrics = function() {
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")
  },
  service_hours = function() {
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$service_hours("daily")
  },
  scheduled_service = function() {
    tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily",
                         route_id = "Red")
  },
  time_predictions = function() tm_time_predictions("Red"),
  aggregate_headways = function() {
    tm_rt_query("Red")$stop("Davis")$direction("southbound")$
      date_range("2024-01-01", "2024-01-31")$aggregate_headways()
  },
  aggregate_dwells = function() {
    tm_rt_query("Red")$stop("Davis")$direction("southbound")$
      date_range("2024-01-01", "2024-01-31")$aggregate_dwells()
  },
  aggregate_travel_times = function() {
    q <- tm_rt_query("Red")$from_stop("Alewife")$to_stop("Park Street")$
      date_range("2025-03-03", "2025-03-07")
    q$aggregate_travel_times()
    q$aggregate_travel_times_v2()
  },
  # Older bus periods have only the fleet fields, not trips and speeds.
  bus_trip_metrics = function() {
    tm_bus_query("1")$date_range("2026-09-01", "2026-09-07")$trip_metrics()
  },
  cr_trip_metrics = function() {
    tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$
      trip_metrics("monthly")
  },
  cr_scorecard = function() {
    tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$
      scorecard("monthly", day_kind = "weekday")
  },
  reliability = function() {
    tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$
      reliability("monthly")
    tm_reliability("RIDE", "2025-01-01", "2025-03-31", agg = "monthly")
  },
  # The leaderboard and weather only have data for recent dates.
  bus_speed_leaderboard = function() {
    tm_bus_speed_leaderboard("2026-09-01", "2026-09-30", limit = 5)
  },
  weather = function() tm_weather("2026-10-01", "2026-10-01")
)

names_wanted <- commandArgs(trailingOnly = TRUE)
if (!length(names_wanted)) names_wanted <- names(calls)
unknown <- setdiff(names_wanted, names(calls))
if (length(unknown)) {
  stop("Unknown call(s): ", paste(unknown, collapse = ", "), call. = FALSE)
}

httptest2::.mockPaths(file.path("tests", "testthat"))
httptest2::start_capturing(simplify = FALSE)
for (name in names_wanted) {
  message("recording ", name)
  calls[[name]]()
}
httptest2::stop_capturing()
