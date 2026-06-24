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

  test_that("tm_headways() returns event records with expected fields", {
    result <- tm_headways("2024-01-15", stop = "70061")
    expect_true(length(result) > 0)
    first <- result[[1]]
    expect_named(
      first,
      c("route_id", "direction", "current_dep_dt",
        "headway_time_sec", "benchmark_headway_time_sec",
        "vehicle_consist", "vehicle_label"),
      ignore.order = TRUE
    )
    expect_equal(first$route_id, "Red")
    headways <- sapply(result, function(x) x$headway_time_sec)
    expect_true(all(headways > 0))
  })

  test_that("tm_travel_times() returns event records with positive travel times", {
    result <- tm_travel_times("2024-01-15",
                              from_stop = "70076", to_stop = "70064")
    expect_true(length(result) > 0)
    first <- result[[1]]
    expect_named(
      first,
      c("route_id", "direction", "dep_dt", "arr_dt",
        "travel_time_sec", "benchmark_travel_time_sec",
        "vehicle_consist", "vehicle_label"),
      ignore.order = TRUE
    )
    travel_times <- sapply(result, function(x) x$travel_time_sec)
    expect_true(all(travel_times > 0))
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

  test_that("tm_ridership() returns weekly counts with positive riders", {
    result <- tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red")
    expect_true(length(result) > 0)
    expect_named(result[[1]], c("date", "count"), ignore.order = TRUE)
    counts <- sapply(result, function(x) x$count)
    expect_true(all(counts > 0))
    # Jan 2024 weekday ridership on Red Line should be >50k/week
    expect_true(all(counts > 50000))
  })

  test_that("tm_line_delays() returns weekly delay records with known fields", {
    result <- tm_line_delays("2024-01-01", "2024-01-31", line = "line-red")
    expect_true(length(result) > 0)
    first <- result[[1]]
    expect_true("total_delay_time" %in% names(first))
    expect_true("date" %in% names(first))
    expect_equal(first$line, "Red")
    total_delays <- sapply(result, function(x) x$total_delay_time)
    expect_true(all(total_delays >= 0))
  })

  test_that("tm_line_delays() agg='daily' returns more records than weekly", {
    weekly <- tm_line_delays("2024-01-01", "2024-01-31", line = "line-red")
    daily  <- tm_line_delays("2024-01-01", "2024-01-31",
                             line = "line-red", agg = "daily")
    expect_true(length(daily) > length(weekly))
  })

  test_that("tm_speed_restrictions() indicates data is available for 2024-01-15", {
    result <- tm_speed_restrictions("line-red", "2024-01-15")
    expect_named(result, c("available", "date", "zones"),
                 ignore.order = TRUE)
    expect_true(isTRUE(result$available))
  })

  test_that("tm_trip_metrics() returns 31 daily records with positive totals", {
    result <- tm_trip_metrics("2024-01-01", "2024-01-31", agg = "daily",
                              line = "line-red")
    expect_equal(length(result), 31)
    expect_named(result[[1]],
                 c("count", "date", "line", "miles_covered", "total_time"),
                 ignore.order = TRUE)
    total_times <- sapply(result, function(x) x$total_time)
    expect_true(all(total_times > 0))
  })

  test_that("tm_service_hours() returns daily scheduled vs delivered hours", {
    result <- tm_service_hours("2024-01-01", "2024-01-31", agg = "daily",
                               line_id = "line-red")
    expect_equal(length(result), 31)
    expect_named(result[[1]], c("date", "scheduled", "delivered"),
                 ignore.order = TRUE)
    scheduled <- sapply(result, function(x) x$scheduled)
    expect_true(all(scheduled > 0))
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

  test_that("tm_aggregate_headways() returns daily headway statistics", {
    result <- tm_aggregate_headways(stop = "70063",
                                    start_date = "2024-01-01",
                                    end_date   = "2024-01-31")
    expect_equal(length(result), 31)
    expect_true("50%" %in% names(result[[1]]))
    medians <- sapply(result, function(x) x[["50%"]])
    expect_true(all(medians > 0))
  })

  test_that("tm_aggregate_dwells() returns daily dwell statistics", {
    result <- tm_aggregate_dwells(stop = "70063",
                                  start_date = "2024-01-01",
                                  end_date   = "2024-01-31")
    expect_equal(length(result), 31)
    expect_true("50%" %in% names(result[[1]]))
    medians <- sapply(result, function(x) x[["50%"]])
    expect_true(all(medians > 0))
  })
})
