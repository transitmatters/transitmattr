test_that("$aggregate_headways() hits headways aggregate endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("aggregate/headways", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
  )
})

test_that("$aggregate_headways() sends single direction's stop ID when direction set", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("stop=70063", req$url))
      expect_false(grepl("stop=70064", req$url))
      mock_response('[]')
    }
  )
  tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
})

test_that("$aggregate_headways() sends date range params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("start_date=2024-01-01", req$url))
      expect_true(grepl("end_date=2024-01-31", req$url))
      mock_response('[]')
    }
  )
  tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
})

test_that("$aggregate_headways() returns a data.frame", {
  httr2::local_mocked_responses(
    function(req) mock_response('[]')
  )
  result <- tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
  expect_s3_class(result, "data.frame")
})

test_that("$aggregate_headways() errors without date range", {
  expect_error(
    tm_rt_query("Red")$stop("Davis")$aggregate_headways(),
    "requires a date range"
  )
})

test_that("$aggregate_headways() errors without stop", {
  expect_error(
    tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$aggregate_headways(),
    "requires a stop"
  )
})

test_that("$aggregate_dwells() hits dwells aggregate endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("aggregate/dwells", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_dwells()
  )
})

test_that("$aggregate_travel_times() uses numeric stop IDs, not place IDs", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("aggregate/traveltimes", req$url))
      # Park Street northbound stop (inferred: order 8 > Davis order 2 = direction 0)
      expect_true(grepl("from_stop=70076", req$url))
      expect_true(grepl("to_stop=70064", req$url))
      expect_false(grepl("place-", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$date_range("2024-01-01", "2024-01-31")$aggregate_travel_times()
  )
})

test_that("$aggregate_travel_times() infers direction from station order", {
  httr2::local_mocked_responses(
    function(req) {
      # Southbound (Davis order 2 < Park Street order 8 = direction 1)
      expect_true(grepl("from_stop=70063", req$url))
      expect_true(grepl("to_stop=70075", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_rt_query("Red")$from_stop("Davis")$to_stop("Park Street")$date_range("2024-01-01", "2024-01-31")$aggregate_travel_times()
  )
})

test_that("$aggregate_travel_times() does not require direction", {
  httr2::local_mocked_responses(
    function(req) mock_response('[]')
  )
  expect_no_error(
    tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$date_range("2024-01-01", "2024-01-31")$aggregate_travel_times()
  )
})
