library(httptest2)

# All tests replay captured fixtures — no network access required.
# To re-record: start_capturing(simplify = FALSE) then re-run the API calls,
# then stop_capturing().

with_mock_api({
  # ── Simple endpoints ────────────────────────────────────────────────────────

  test_that("tm_routes() returns all five rapid transit lines", {
    result <- tm_routes()
    rapid <- unlist(result$rapid_transit)
    expect_setequal(rapid, c("Red", "Orange", "Blue", "Green", "Mattapan"))
    expect_true(length(result$bus) > 0)
    expect_true(length(result$commuter_rail) > 0)
  })

  test_that("tm_stops() returns expected structure for Red Line", {
    result <- tm_stops("Red")
    expect_named(result, c("type", "direction", "stations"),
                 ignore.order = TRUE)
    expect_true(length(result$stations) > 0)
  })

  # ── Dated endpoints ─────────────────────────────────────────────────────────

  test_that("$headways() returns event records with expected fields", {
    # Alewife has stop ID 70061 (both directions) — matches recorded fixture
    result <- tm_rt_query("Red")$stop("Alewife")$headways("2024-01-15")
    expect_true(nrow(result) > 0)
    expect_named(
      result,
      c("route_id", "direction", "current_dep_dt",
        "headway_time_sec", "benchmark_headway_time_sec",
        "vehicle_consist", "vehicle_label"),
      ignore.order = TRUE
    )
    expect_equal(result$route_id[1], "Red")
    expect_true(all(result$headway_time_sec > 0))
  })

  test_that("$travel_times() returns event records with positive travel times", {
    # Park Street northbound (70076) → Davis northbound (70064)
    result <- tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$direction("northbound")$travel_times("2024-01-15")
    expect_true(nrow(result) > 0)
    expect_named(
      result,
      c("route_id", "direction", "dep_dt", "arr_dt",
        "travel_time_sec", "benchmark_travel_time_sec",
        "tm_benchmark_travel_time_sec", "vehicle_consist", "vehicle_label"),
      ignore.order = TRUE
    )
    expect_true(all(result$travel_time_sec > 0))
  })

  test_that("tm_alerts() returns alerts with text and timestamps", {
    result <- tm_alerts("2024-01-15", route = "Red")
    expect_true(length(result) > 0)
    first <- result[[1]]
    expect_true(!is.null(first$valid_from))
    expect_true(!is.null(first$text))
    expect_match(first$text, "Red Line", ignore.case = TRUE)
  })

  # ── Parameterized endpoints ─────────────────────────────────────────────────

  test_that("$ridership() returns weekly counts with positive riders", {
    result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$ridership()
    expect_true(nrow(result) > 0)
    expect_named(result, c("date", "count"), ignore.order = TRUE)
    expect_true(all(result$count > 0))
    expect_true(all(result$count > 50000))
  })

  test_that("$line_delays() returns weekly delay records with known fields", {
    result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays()
    expect_true(nrow(result) > 0)
    expect_true("total_delay_time" %in% names(result))
    expect_true("date" %in% names(result))
    expect_equal(result$line[1], "Red")
    expect_true(all(result$total_delay_time >= 0))
  })

  test_that("$line_delays() agg='daily' returns more records than weekly", {
    weekly <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays()
    daily  <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays("daily")
    expect_true(nrow(daily) > nrow(weekly))
  })

  test_that("$speed_restrictions() indicates data is available for 2024-01-15", {
    result <- tm_rt_query("Red")$speed_restrictions("2024-01-15")
    expect_named(result, c("available", "date", "zones"),
                 ignore.order = TRUE)
    expect_true(isTRUE(result$available))
  })

  test_that("$trip_metrics() returns 31 daily records with positive totals", {
    result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")
    expect_equal(nrow(result), 31)
    # Entries also have fleet fields, some (fleet_mix_<type>) undocumented.
    expect_true(all(c("count", "date", "line", "miles_covered", "total_time")
                    %in% names(result)))
    expect_true(all(result$total_time > 0))
  })

  test_that("$service_hours() returns daily scheduled vs delivered hours", {
    result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$service_hours("daily")
    expect_equal(nrow(result), 31)
    expect_named(result, c("date", "scheduled", "delivered"),
                 ignore.order = TRUE)
    expect_true(all(result$scheduled > 0))
  })

  test_that("tm_scheduled_service() returns service level metadata", {
    result <- tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily",
                                   route_id = "Red")
    expect_true("start_date" %in% names(result))
    expect_true("counts" %in% names(result))
    expect_equal(result$start_date, as.Date("2024-01-01"))
    expect_equal(result$end_date, as.Date("2024-01-31"))
  })

  test_that("tm_time_predictions() returns prediction records for Red Line", {
    result <- tm_time_predictions("Red")
    expect_true(length(result) > 0)
    expect_true("prediction" %in% names(result[[1]]))
  })

  # ── Aggregate endpoints ─────────────────────────────────────────────────────

  test_that("$aggregate_headways() returns daily headway statistics", {
    # Davis southbound (70063) — matches recorded fixture (no direction_id in URL)
    result <- tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
    expect_equal(nrow(result), 31)
    expect_true("50%" %in% names(result))
    expect_true(all(result[["50%"]] > 0))
  })

  test_that("$aggregate_dwells() returns daily dwell statistics", {
    result <- tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_dwells()
    expect_equal(nrow(result), 31)
    expect_true("50%" %in% names(result))
    expect_true(all(result[["50%"]] > 0))
  })

  test_that("$aggregate_travel_times() returns daily travel time statistics", {
    # Alewife (70061) southbound to Park Street (70075)
    result <- tm_rt_query("Red")$from_stop("Alewife")$to_stop("Park Street")$date_range("2025-03-03", "2025-03-07")$aggregate_travel_times()
    expect_equal(nrow(result), 5)
    expect_true(all(c("service_date", "50%", "count") %in% names(result)))
    expect_true(all(result[["50%"]] > 0))
  })

  test_that("$aggregate_travel_times_v2() returns by-date and by-time statistics", {
    result <- tm_rt_query("Red")$from_stop("Alewife")$to_stop("Park Street")$date_range("2025-03-03", "2025-03-07")$aggregate_travel_times_v2()
    expect_named(result, c("by_date", "by_time"))
    expect_true(nrow(result$by_date) > 0)
    expect_true(nrow(result$by_time) > 0)
    expect_true("dep_time_from_epoch" %in% names(result$by_time))
  })

  # ── Bus, commuter rail, and system-wide endpoints ───────────────────────────

  test_that("bus $trip_metrics() returns daily trips and speeds", {
    result <- tm_bus_query("1")$date_range("2026-09-01", "2026-09-07")$trip_metrics()
    expect_equal(nrow(result), 7)
    expect_true(all(c("date", "route", "count", "miles_covered",
                      "median_speed_mph") %in% names(result)))
    expect_true(all(result$route == "1"))
    expect_true(all(result$count > 0))
  })

  test_that("CR $trip_metrics() returns monthly fleet mix", {
    result <- tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$trip_metrics("monthly")
    expect_equal(nrow(result), 3)
    expect_true(all(c("date", "fleet_trips") %in% names(result)))
    expect_true(any(startsWith(names(result), "fleet_mix_")))
  })

  test_that("CR $scorecard() returns per-direction scores", {
    result <- tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$scorecard("monthly", day_kind = "weekday")
    expect_equal(nrow(result), 3)
    expect_true(all(c("date", "days", "outbound", "inbound") %in% names(result)))
    expect_true(all(result$outbound$trips > 0))
  })

  test_that("CR $reliability() returns on-time counts with peak split", {
    result <- tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$reliability("monthly")
    expect_equal(nrow(result), 3)
    expect_true(all(result$otpNumerator <= result$otpDenominator))
    expect_true(all(c("otpNumerator", "otpDenominator") %in% names(result$peak)))
  })

  test_that("tm_reliability('RIDE') returns completed and on-time trips", {
    result <- tm_reliability("RIDE", "2025-01-01", "2025-03-31", agg = "monthly")
    expect_equal(nrow(result), 3)
    expect_true(all(result$onTime <= result$completed))
  })

  test_that("tm_bus_speed_leaderboard() returns at most `limit` routes", {
    result <- tm_bus_speed_leaderboard("2026-09-01", "2026-09-30", limit = 5)
    expect_equal(nrow(result), 5)
    expect_named(result,
                 c("route", "count", "total_time", "miles_covered", "n_traversals"),
                 ignore.order = TRUE)
  })

  test_that("tm_weather() returns one row per hour", {
    result <- tm_weather("2026-10-01", "2026-10-01")
    expect_equal(nrow(result), 24)
    expect_true(all(c("timestamp", "temperature_f", "condition") %in% names(result)))
  })

  # ── Date ranges ──────────────────────────────────────────────────────────────

  test_that("$headways() over a date range returns both days' departures", {
    one_day <- tm_rt_query("Red")$stop("Alewife")$headways("2024-01-15")
    result <- tm_rt_query("Red")$stop("Alewife")$date_range("2024-01-15", "2024-01-16")$headways()
    expect_gt(nrow(result), nrow(one_day))
    # Service days run past midnight, until about 3:30 AM the next day.
    times <- result$current_dep_dt
    expect_equal(format(min(times), "%Y-%m-%d"), "2024-01-15")
    expect_lt(max(times), as.POSIXct("2024-01-17 04:00", tz = "America/New_York"))
    expect_true(any(format(times, "%Y-%m-%d") == "2024-01-16"))
  })

  test_that("$trip_metrics() over more than 150 days returns every day once", {
    result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-07-31")$trip_metrics("daily")
    expect_equal(nrow(result), 213)
    expect_equal(result$date, seq(as.Date("2024-01-01"), as.Date("2024-07-31"), by = "day"))
  })

  # ── Types ────────────────────────────────────────────────────────────────────

  test_that("event times are Eastern date-times", {
    result <- tm_rt_query("Red")$stop("Alewife")$headways("2024-01-15")
    expect_s3_class(result$current_dep_dt, "POSIXct")
    expect_equal(attr(result$current_dep_dt, "tzone"), "America/New_York")
    expect_equal(format(result$current_dep_dt[1], "%Y-%m-%d %H:%M:%S %Z"),
                 "2024-01-15 05:27:12 EST")
    expect_type(result$direction, "integer")

    trips <- tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$direction("northbound")$travel_times("2024-01-15")
    expect_s3_class(trips$dep_dt, "POSIXct")
    expect_true(all(trips$arr_dt > trips$dep_dt))
  })

  test_that("alert times with a UTC offset are Eastern date-times", {
    alert <- tm_alerts("2024-01-15", route = "Red")[[1]]
    expect_s3_class(alert$valid_from, "POSIXct")
    expect_equal(format(alert$valid_from, "%H:%M"), "05:58")
  })

  test_that("dates are Dates", {
    expect_s3_class(
      tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()$service_date,
      "Date"
    )
    expect_s3_class(tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$ridership()$date, "Date")
    expect_s3_class(tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$scorecard("monthly", day_kind = "weekday")$date, "Date")
    result <- tm_rt_query("Red")$speed_restrictions("2024-01-15")
    expect_s3_class(result$date, "Date")
    expect_s3_class(result$zones[[1]]$reported, "Date")
  })

  test_that("times of day are hms", {
    result <- tm_rt_query("Red")$from_stop("Alewife")$to_stop("Park Street")$date_range("2025-03-03", "2025-03-07")$aggregate_travel_times_v2()
    expect_s3_class(result$by_time$dep_time_from_epoch, "hms")
    expect_equal(format(result$by_time$dep_time_from_epoch[1]), "05:30:00")
    expect_s3_class(result$by_date$service_date, "Date")
  })

  test_that("weather timestamps are Eastern date-times", {
    result <- tm_weather("2026-10-01", "2026-10-01")
    expect_s3_class(result$timestamp, "POSIXct")
    expect_equal(format(result$timestamp[c(1, 24)], "%H:%M"), c("00:00", "23:00"))
  })
})
