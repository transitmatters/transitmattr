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

test_that(".tm_call() retries cold-start statuses, then succeeds", {
  sleeps <- numeric()
  local_mocked_bindings(.tm_sleep = function(seconds) sleeps <<- c(sleeps, seconds))
  statuses <- c(503L, 429L, 200L)
  httr2::local_mocked_responses(function(req) {
    status <- statuses[[1]]
    statuses <<- statuses[-1]
    mock_response('[{"a": 1}]', status = status)
  })
  result <- transitmattr:::.tm_call("get_routes", simplify = TRUE)
  expect_equal(result$a, 1)
  expect_equal(sleeps, c(2, 4))
})

test_that(".tm_call() gives up after max_tries and raises an httr2 error", {
  local_mocked_bindings(.tm_sleep = function(seconds) NULL)
  calls <- 0
  httr2::local_mocked_responses(function(req) {
    calls <<- calls + 1
    mock_response('{"error": "cold"}', status = 503L)
  })
  expect_error(transitmattr:::.tm_call("get_routes"), class = "httr2_http_503")
  expect_equal(calls, 3)
})

test_that(".tm_call() doesn't retry a 400, and includes the body", {
  calls <- 0
  httr2::local_mocked_responses(function(req) {
    calls <<- calls + 1
    mock_response('{"error": "start_date is required"}', status = 400L)
  })
  expect_error(
    transitmattr:::.tm_call("get_routes"),
    "start_date is required",
    class = "httr2_http_400"
  )
  expect_equal(calls, 1)
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
