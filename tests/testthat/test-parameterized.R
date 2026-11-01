test_that("$ridership() sends start_date and end_date as query params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("start_date=2024-01-01", req$url))
      expect_true(grepl("end_date=2024-01-31", req$url))
      mock_response('[]')
    }
  )
  result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$ridership()
  expect_s3_class(result, "data.frame")
})

test_that("$ridership() sends normalized line_id", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("line_id=line-Red", req$url))
      mock_response('[]')
    }
  )
  for (input in c("red", "Red", "line-red", "line-Red")) {
    tm_rt_query(input)$date_range("2024-01-01", "2024-01-31")$ridership()
  }
})

test_that("tm_time_predictions sends route_id", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("time_predictions", req$url))
      expect_true(grepl("route_id=Red", req$url))
      mock_response('{"predictions":{}}')
    }
  )
  expect_no_error(tm_time_predictions("Red"))
})

test_that("tm_time_predictions sends start_date and end_date", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("start_date=2024-01-01", req$url))
      expect_true(grepl("end_date=2024-01-31", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_time_predictions("Red", as.Date("2024-01-01"), "2024-01-31")
  )
})

test_that("tm_time_predictions omits dates it isn't given", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("start_date", req$url))
      expect_false(grepl("end_date", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_time_predictions("Red"))
})

test_that("$line_delays() sends required params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("linedelays", req$url))
      expect_true(grepl("line=Red", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays()
  )
})

test_that("$line_delays() sends agg when provided", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("agg=daily", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays("daily")
  )
})

test_that("$line_delays() sends the spec's default agg when not provided", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("agg=weekly", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays()
  )
})

test_that("$line_delays() normalizes line to title-case color", {
  for (input in c("red", "Red", "line-red", "line-Red")) {
    httr2::local_mocked_responses(
      function(req) {
        expect_true(grepl("line=Red", req$url),
                    label = paste("line=Red in URL for input:", input))
        mock_response('[]')
      }
    )
    tm_rt_query(input)$date_range("2024-01-01", "2024-01-31")$line_delays()
  }
})

test_that("$trip_metrics() sends agg param", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("agg=daily", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")
  )
})

test_that("$trip_metrics() normalizes line to line-red", {
  for (input in c("red", "Red", "line-red", "line-Red")) {
    httr2::local_mocked_responses(
      function(req) {
        expect_true(grepl("line=line-red", req$url),
                    label = paste("line=line-red in URL for input:", input))
        mock_response('[]')
      }
    )
    tm_rt_query(input)$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")
  }
})

test_that("tm_scheduled_service (standalone) requires route_id", {
  expect_error(
    tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily"),
    "route_id"
  )
})

test_that("$scheduled_service() returns the same list as tm_scheduled_service()", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("route_id=Red", req$url))
      expect_true(grepl("agg=monthly", req$url))
      mock_response('{"start_date": "2024-01-01", "counts": [1, 2]}')
    }
  )
  result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-03-31")$scheduled_service("monthly")
  expect_equal(result$start_date, as.Date("2024-01-01"))
  expect_length(result$counts, 2)
})

test_that("$service_hours() rejects an agg the spec doesn't allow", {
  httr2::local_mocked_responses(function(req) mock_response('[]'))
  expect_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$service_hours("yearly"),
    "Invalid value for agg"
  )
})

# ── New endpoints ─────────────────────────────────────────────────────────────

test_that("bus $trip_metrics() sends route and optional filters", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("api/bustripmetrics", req$url))
      expect_true(grepl("route=1&", req$url))
      expect_true(grepl("time_band=am_peak", req$url))
      expect_true(grepl("day_type=business_day", req$url))
      mock_response('[]')
    }
  )
  result <- tm_bus_query("1")$date_range("2025-03-01", "2025-03-31")$
    trip_metrics(time_band = "am_peak", day_type = "business_day")
  expect_s3_class(result, "data.frame")
})

test_that("bus $trip_metrics() sends combined routes comma-separated", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("route=104%2C109", req$url))
      mock_response('[]')
    }
  )
  tm_bus_query("104/109")$date_range("2025-03-01", "2025-03-31")$trip_metrics()
})

test_that("bus $trip_metrics() requires a date range", {
  expect_error(tm_bus_query("1")$trip_metrics(), "date range")
})

test_that("CR $trip_metrics(), $reliability(), and $scorecard() send the route", {
  urls <- character()
  httr2::local_mocked_responses(
    function(req) {
      urls <<- c(urls, req$url)
      mock_response('[]')
    }
  )
  q <- tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")
  q$trip_metrics("monthly")
  q$reliability("monthly")
  q$scorecard("weekly", day_kind = "saturday")
  expect_match(urls[1], "api/crtripmetrics\\?.*route=CR-Worcester&agg=monthly")
  expect_match(urls[2], "api/reliability\\?route_id=CR-Worcester&.*agg=monthly")
  expect_match(urls[3], "api/crscorecard\\?route_id=CR-Worcester&.*agg=weekly&day_kind=saturday")
})

test_that("CR $scorecard() rejects an unknown day_kind", {
  httr2::local_mocked_responses(function(req) mock_response('[]'))
  expect_error(
    tm_cr_query("CR-Worcester")$date_range("2025-01-01", "2025-03-31")$scorecard("weekly", day_kind = "friday"),
    "Invalid value for day_kind"
  )
})

test_that("$aggregate_travel_times_v2() returns by_date and by_time data.frames", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("api/aggregate/traveltimes2", req$url))
      mock_response('{"by_date": [], "by_time": []}')
    }
  )
  result <- tm_rt_query("Red")$from_stop("Alewife")$to_stop("Park Street")$
    date_range("2025-03-03", "2025-03-07")$aggregate_travel_times_v2()
  expect_named(result, c("by_date", "by_time"))
  expect_s3_class(result$by_date, "data.frame")
  expect_s3_class(result$by_time, "data.frame")
})

test_that("tm_reliability(), tm_bus_speed_leaderboard(), tm_weather() send dates", {
  urls <- character()
  httr2::local_mocked_responses(
    function(req) {
      urls <<- c(urls, req$url)
      mock_response('[]')
    }
  )
  expect_s3_class(
    tm_reliability("RIDE", as.Date("2025-01-01"), "2025-03-31", agg = "monthly"),
    "data.frame"
  )
  expect_s3_class(tm_bus_speed_leaderboard("2025-03-01", "2025-03-31", limit = 5),
                  "data.frame")
  expect_s3_class(tm_weather("2025-03-01", "2025-03-02"), "data.frame")
  expect_match(urls[1], "route_id=RIDE&start_date=2025-01-01&end_date=2025-03-31&agg=monthly")
  expect_match(urls[2], "busspeedleaderboard\\?start_date=2025-03-01&end_date=2025-03-31&limit=5")
  expect_match(urls[3], "weather\\?start_date=2025-03-01&end_date=2025-03-02")
})

test_that("$speed_restrictions() sends line_id and date", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("speed_restrictions", req$url))
      expect_true(grepl("date=2024-01-15", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_rt_query("Red")$speed_restrictions("2024-01-15"))
})

test_that("$service_hours() sends required params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("service_hours", req$url))
      expect_true(grepl("agg=weekly", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$service_hours("weekly")
  )
})

test_that("$service_hours() accepts Date objects", {
  httr2::local_mocked_responses(
    function(req) mock_response('[]')
  )
  expect_no_error(
    tm_rt_query("Red")$date_range(as.Date("2024-01-01"), as.Date("2024-01-31"))$service_hours("daily")
  )
})
