test_that("tm_aggregate_travel_times sends query params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("from_stop=place-pktrm", req$url))
      expect_true(grepl("to_stop=place-davis", req$url))
      mock_response('{"data":{}}')
    }
  )
  result <- tm_aggregate_travel_times(
    from_stop = "place-pktrm", to_stop = "place-davis",
    start_date = "2024-01-01", end_date = "2024-01-31"
  )
  expect_true("data" %in% names(result))
})

test_that("tm_aggregate_travel_times2 hits traveltimes2 path", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("traveltimes2", req$url))
      mock_response('{"data":{}}')
    }
  )
  expect_no_error(
    tm_aggregate_travel_times2(
      from_stop = "place-pktrm", to_stop = "place-davis",
      start_date = "2024-01-01", end_date = "2024-01-31"
    )
  )
})

test_that("tm_aggregate_headways hits headways path", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("aggregate/headways", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_aggregate_headways(stop = "place-davis",
                                        start_date = "2024-01-01",
                                        end_date = "2024-01-31"))
})

test_that("tm_aggregate_dwells hits dwells path", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("aggregate/dwells", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_aggregate_dwells(stop = "place-davis",
                                      start_date = "2024-01-01",
                                      end_date = "2024-01-31"))
})
