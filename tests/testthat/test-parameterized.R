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

test_that("$line_delays() omits agg when not provided", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("agg", req$url))
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

test_that("tm_scheduled_service (standalone) omits route_id when NULL", {
  httr2::local_mocked_responses(
    function(req) {
      expect_false(grepl("route_id", req$url))
      mock_response('[]')
    }
  )
  expect_no_error(tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily"))
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
