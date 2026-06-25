test_that("$headways() returns a data.frame", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  result <- tm_rt_query("Red")$stop("Alewife")$headways("2024-01-15")
  expect_s3_class(result, "data.frame")
})

test_that("$headways() accepts a Date object", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  expect_no_error(
    tm_rt_query("Red")$stop("Alewife")$date(as.Date("2024-01-15"))$headways()
  )
})

test_that("$headways() errors without a date", {
  expect_error(
    tm_rt_query("Red")$stop("Alewife")$headways(),
    "requires a date"
  )
})

test_that("$headways() errors without a stop", {
  expect_error(
    tm_rt_query("Red")$date("2024-01-15")$headways(),
    "requires a stop"
  )
})

test_that("$headways() hits the correct endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("/api/headways/2024-01-15", req$url))
      expect_true(grepl("stop=70061", req$url))
      mock_response("[]")
    }
  )
  tm_rt_query("Red")$stop("Alewife")$headways("2024-01-15")
})

test_that("$headways() with direction restricts to one direction's stop IDs", {
  httr2::local_mocked_responses(
    function(req) {
      # Davis southbound is 70063; northbound is 70064
      expect_true(grepl("stop=70063", req$url))
      expect_false(grepl("stop=70064", req$url))
      mock_response("[]")
    }
  )
  tm_rt_query("Red")$stop("Davis")$direction("southbound")$headways("2024-01-15")
})

test_that("$dwells() returns a data.frame", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  result <- tm_rt_query("Red")$stop("Alewife")$dwells("2024-01-15")
  expect_s3_class(result, "data.frame")
})

test_that("$dwells() errors without a date", {
  expect_error(
    tm_rt_query("Red")$stop("Alewife")$dwells(),
    "requires a date"
  )
})

test_that("$travel_times() returns a data.frame", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  result <- tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$direction("northbound")$travel_times("2024-01-15")
  expect_s3_class(result, "data.frame")
})

test_that("$travel_times() hits correct endpoint with stop IDs", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("/api/traveltimes/2024-01-15", req$url))
      expect_true(grepl("from_stop=70076", req$url))
      expect_true(grepl("to_stop=70064", req$url))
      mock_response("[]")
    }
  )
  tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$direction("northbound")$travel_times("2024-01-15")
})

test_that("$travel_times() errors without direction", {
  expect_error(
    tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$travel_times("2024-01-15"),
    "requires a direction"
  )
})

test_that("$travel_times() errors without from/to stops", {
  expect_error(
    tm_rt_query("Red")$direction("northbound")$travel_times("2024-01-15"),
    "requires from/to stops"
  )
})

test_that("tm_alerts with no date hits undated endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("/alerts/", req$url))
      mock_response('{"alerts":[]}')
    }
  )
  result <- tm_alerts(route = "Red")
  expect_true("alerts" %in% names(result))
})

test_that("tm_alerts with a date hits dated endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("/alerts/2024-01-15", req$url))
      mock_response('{"alerts":[]}')
    }
  )
  result <- tm_alerts("2024-01-15", route = "Red")
  expect_true("alerts" %in% names(result))
})
