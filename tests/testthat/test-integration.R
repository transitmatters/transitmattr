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
        "vehicle_consist", "vehicle_label"),
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
    expect_named(result,
                 c("count", "date", "line", "miles_covered", "total_time"),
                 ignore.order = TRUE)
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
    expect_equal(result$start_date, "2024-01-01")
    expect_equal(result$end_date, "2024-01-31")
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
})
