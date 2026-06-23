test_that("tm_ridership sends start_date, end_date as query params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("start_date=2024-01-01", req$url))
      expect_true(grepl("end_date=2024-01-31", req$url))
      mock_response('[]')
    }
  )
  result <- tm_ridership("2024-01-01", "2024-01-31")
  expect_type(result, "list")
})

test_that("tm_ridership sends line_id when provided", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("line_id=line-red", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red"))
})

test_that("tm_ridership omits line_id when NULL", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("line_id", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_ridership("2024-01-01", "2024-01-31"))
})

test_that("tm_line_delays sends required params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("linedelays", req$url))
      expect_true(grepl("line=line-red", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_line_delays("2024-01-01", "2024-01-31", line = "line-red"))
})

test_that("tm_trip_metrics sends agg param", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("agg=daily", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(
    tm_trip_metrics("2024-01-01", "2024-01-31", agg = "daily", line = "line-red")
  )
})

test_that("tm_scheduled_service omits route_id when NULL", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("route_id", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily"))
})

test_that("tm_speed_restrictions sends line_id and on_date", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("speed_restrictions", req$url))
      expect_true(grepl("on_date=2024-01-15", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_speed_restrictions("line-red", "2024-01-15"))
})

test_that("tm_service_hours sends required params", {
  httr2::local_mocked_responses(
    function(req) {
      expect_true(grepl("service_hours", req$url))
      expect_true(grepl("agg=weekly", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_service_hours("2024-01-01", "2024-01-31", agg = "weekly"))
})

test_that("tm_service_hours accepts Date objects", {
  httr2::local_mocked_responses(
    function(req) mock_response('[]')
  )
  expect_no_error(
    tm_service_hours(as.Date("2024-01-01"), as.Date("2024-01-31"), agg = "daily")
  )
})
