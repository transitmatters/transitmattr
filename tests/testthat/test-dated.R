test_that("tm_headways returns a list", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  result <- tm_headways("2024-01-15", stop = "70061")
  expect_type(result, "list")
})

test_that("tm_headways accepts a Date object", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  expect_no_error(tm_headways(as.Date("2024-01-15"), stop = "70061"))
})

test_that("tm_dwells returns a list", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  result <- tm_dwells("2024-01-15", stop = "70061")
  expect_type(result, "list")
})

test_that("tm_travel_times returns a list", {
  httr2::local_mocked_responses(
    function(req) mock_response("[]")
  )
  result <- tm_travel_times("2024-01-15",
    from_stop = "70076", to_stop = "70064")
  expect_type(result, "list")
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
