# Tests for .tm_call(), the adapter between the package and the generated
# ApiApi in R/generated-*.R.

test_that("every generated operation is wrapped", {
  generated <- names(transitmattr:::ApiApi$public_methods)
  generated <- grep("^get_", generated, value = TRUE)
  generated <- generated[!grepl("_with_http_info$", generated)]
  wrapped <- names(transitmattr:::.tm_wrapped_ops)
  # A new endpoint in the spec: wrap it, then add it to .tm_wrapped_ops.
  expect_setequal(generated, wrapped)
})

test_that(".tm_call() rejects an operation the API doesn't have", {
  expect_error(transitmattr:::.tm_call("get_git_id"), "no operation `get_git_id`")
})

test_that(".tm_call() rejects a parameter the operation doesn't have", {
  expect_error(
    transitmattr:::.tm_call("get_headways", user_date = "2024-01-15", stops = "1"),
    "`get_headways` has no parameter `stops`"
  )
})

test_that(".tm_call() reports a missing required parameter", {
  expect_error(transitmattr:::.tm_call("get_headways"), "user_date")
})

test_that(".tm_call() sends several values of a parameter as repeated keys", {
  httr2::local_mocked_responses(
    function(req) {
      expect_match(req$url, "/api/headways/2024-01-15\\?stop=70061&stop=70062$")
      mock_response('[]')
    }
  )
  transitmattr:::.tm_call("get_headways", user_date = "2024-01-15",
                          stop = c("70061", "70062"))
})

test_that(".tm_call() percent-encodes slashes in path parameters", {
  httr2::local_mocked_responses(
    function(req) {
      expect_match(req$url, "/api/stops/SL4%2FSL5$")
      mock_response('{}')
    }
  )
  tm_stops("SL4/SL5")
})

test_that(".tm_call() sends the package user agent", {
  httr2::local_mocked_responses(
    function(req) {
      expect_match(req$options$useragent, "^transitmattr/")
      mock_response('[]')
    }
  )
  tm_routes()
})

# httr2's mocks skip retries, so these check the retry policy each request
# is built with rather than replaying a sequence of responses.
test_that("requests retry rate limits, gateway errors, and failed connections", {
  req <- transitmattr:::.tm_request("get_routes")
  is_transient <- req$policies$retry_is_transient
  for (status in c(429L, 502L, 503L, 504L)) {
    expect_true(is_transient(httr2::response(status)), label = status)
  }
  for (status in c(400L, 403L, 404L, 500L)) {
    expect_false(is_transient(httr2::response(status)), label = status)
  }
  expect_equal(req$policies$retry_max_tries, 4)
  expect_true(req$policies$retry_on_failure)
  expect_equal(req$options$timeout_ms, 30000)
})

test_that("retries back off exponentially up to 8 seconds", {
  for (attempt in 1:6) {
    delay <- transitmattr:::.tm_backoff(attempt)
    cap <- min(8, 0.5 * 2^attempt)
    expect_gte(delay, cap / 2)
    expect_lte(delay, cap)
  }
})

test_that("a 400 raises transitmattr_bad_request with the API's message", {
  httr2::local_mocked_responses(function(req) {
    mock_response('{"Code": "BadRequestError", "Message": "Missing or invalid parameters."}',
                  status = 400L)
  })
  err <- expect_error(transitmattr:::.tm_call("get_routes"),
                      class = "transitmattr_bad_request")
  expect_s3_class(err, "transitmattr_http_error")
  expect_s3_class(err, "transitmattr_error")
  # The classes httr2 raised before 0.3.0, for existing handlers.
  expect_s3_class(err, "httr2_http_400")
  expect_equal(err$status, 400L)
  expect_equal(err$code, "BadRequestError")
  expect_match(err$content, '"Code": "BadRequestError"', fixed = TRUE)
  expect_match(conditionMessage(err), "HTTP 400 Bad Request \\(BadRequestError\\)")
  expect_match(conditionMessage(err), "Missing or invalid parameters.")
  # The raw body is in `content`, not repeated in the message.
  expect_no_match(conditionMessage(err), '"Code"', fixed = TRUE)
})

test_that("a 403 raises transitmattr_range_too_long", {
  httr2::local_mocked_responses(function(req) {
    mock_response('{"Code": "ForbiddenError", "Message": "Date range too long."}',
                  status = 403L)
  })
  expect_error(tm_bus_speed_leaderboard("2025-01-01", "2025-12-31"),
               "Request a shorter date range",
               class = "transitmattr_range_too_long")
})

test_that("a 404 raises transitmattr_not_found with the API's message", {
  httr2::local_mocked_responses(function(req) {
    mock_response('{"error": "Route \'Purple\' not found"}', status = 404L)
  })
  expect_error(tm_stops("Purple"), "Route 'Purple' not found",
               class = "transitmattr_not_found")
  # Handlers written for httr2's errors still catch it.
  expect_null(tryCatch(tm_stops("Purple"), httr2_http_404 = function(e) NULL))
})

test_that("a 500 raises transitmattr_server_error with the body", {
  httr2::local_mocked_responses(function(req) {
    mock_response('{"Code": "InternalServerError", "Message": "An internal server error occurred."}',
                  status = 500L)
  })
  expect_error(transitmattr:::.tm_call("get_routes"),
               "An internal server error occurred",
               class = "transitmattr_server_error")
})

test_that("no response raises transitmattr_network_error", {
  httr2::local_mocked_responses(function(req) {
    rlang::abort("Couldn't connect", class = c("httr2_failure", "httr2_error"))
  })
  err <- expect_error(tm_routes(), class = "transitmattr_network_error")
  expect_s3_class(err$parent, "httr2_failure")
})

test_that("several requests are sent in parallel and their errors raised", {
  httr2::local_mocked_responses(function(req) {
    if (grepl("2024-01-16", req$url)) {
      mock_response('{"error": "nope"}', status = 404L)
    } else {
      mock_response('[]')
    }
  })
  expect_error(
    tm_rt_query("Red")$stop("Davis")$date_range("2024-01-15", "2024-01-17")$headways(),
    class = "transitmattr_not_found"
  )
})

test_that("tm_healthcheck() returns a failing check instead of an error", {
  calls <- 0
  httr2::local_mocked_responses(function(req) {
    calls <<- calls + 1
    mock_response('{"status": "fail", "failed_checks": ["db"]}', status = 500L)
  })
  result <- tm_healthcheck()
  expect_equal(result$status, "fail")
  expect_equal(calls, 1)
})
