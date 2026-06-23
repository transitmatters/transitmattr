test_that("tm_headways returns headways field", {
  httr2::local_mocked_responses(
    function(req) mock_response('{"headways":{"Red":[]}}')
  )
  result <- tm_headways("2024-01-15")
  expect_true("headways" %in% names(result))
})

test_that("tm_headways accepts a Date object", {
  httr2::local_mocked_responses(
    function(req) mock_response('{"headways":{}}')
  )
  expect_no_error(tm_headways(as.Date("2024-01-15")))
})

test_that("tm_dwells returns dwells field", {
  httr2::local_mocked_responses(
    function(req) mock_response('{"dwells":{"Red":[]}}')
  )
  result <- tm_dwells("2024-01-15")
  expect_true("dwells" %in% names(result))
})

test_that("tm_travel_times returns travel_times field", {
  httr2::local_mocked_responses(
    function(req) mock_response('{"travel_times":{"Red":[]}}')
  )
  result <- tm_travel_times("2024-01-15")
  expect_true("travel_times" %in% names(result))
})

test_that("tm_alerts with no date hits undated endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("/alerts/", req$url))
      mock_response('{"alerts":[]}')
    }
  )
  result <- tm_alerts()
  expect_true("alerts" %in% names(result))
})

test_that("tm_alerts with a date hits dated endpoint", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("/alerts/2024-01-15", req$url))
      mock_response('{"alerts":[]}')
    }
  )
  result <- tm_alerts("2024-01-15")
  expect_true("alerts" %in% names(result))
})
