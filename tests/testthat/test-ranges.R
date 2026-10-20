# Tests for date ranges: per-day methods over $date_range(), and trip metrics
# split into spans the API accepts.

spans_as_text <- function(spans) {
  vapply(spans, function(span) paste(format(span), collapse = ".."), "")
}

# Mock that records each request's URL and answers with `body(url)`.
record_requests <- function(body = function(url) "[]", env = parent.frame()) {
  urls <- character()
  httr2::local_mocked_responses(function(req) {
    urls <<- c(urls, req$url)
    mock_response(body(req$url))
  }, env = env)
  function() urls
}

test_that(".tm_spans() splits daily ranges into 150-day spans", {
  spans <- transitmattr:::.tm_spans("2024-01-01", "2024-12-31", "daily")
  expect_equal(spans_as_text(spans), c("2024-01-01..2024-05-29",
                                       "2024-05-30..2024-10-26",
                                       "2024-10-27..2024-12-31"))
})

test_that(".tm_spans() breaks weekly spans on Mondays", {
  spans <- transitmattr:::.tm_spans("2020-01-01", "2024-12-31", "weekly")
  starts <- as.Date(vapply(spans[-1], function(span) format(span[[1]]), ""))
  expect_true(length(spans) > 1)
  expect_true(all(format(starts, "%u") == "1"))
  # Contiguous, covering the whole range.
  ends <- do.call(c, lapply(spans, `[[`, 2))
  expect_equal(starts, head(ends, -1) + 1)
  expect_equal(format(spans[[length(spans)]][[2]]), "2024-12-31")
})

test_that(".tm_spans() breaks monthly spans on the 1st", {
  spans <- transitmattr:::.tm_spans("2000-01-15", "2024-12-31", "monthly")
  starts <- vapply(spans[-1], function(span) format(span[[1]], "%d"), "")
  expect_true(length(spans) > 1)
  expect_true(all(starts == "01"))
})

test_that(".tm_spans() leaves short, backwards, and unknown ranges whole", {
  expect_length(transitmattr:::.tm_spans("2024-01-01", "2024-01-31", "daily"), 1)
  expect_length(transitmattr:::.tm_spans("2024-12-31", "2024-01-01", "daily"), 1)
  expect_length(transitmattr:::.tm_spans("2000-01-01", "2024-12-31", "yearly"), 1)
})

test_that(".tm_days() lists every day, and rejects a backwards range", {
  expect_equal(transitmattr:::.tm_days("2024-02-28", as.Date("2024-03-01")),
               c("2024-02-28", "2024-02-29", "2024-03-01"))
  expect_error(transitmattr:::.tm_days("2024-01-02", "2024-01-01"), "before")
})

test_that(".tm_bind_rows() fills missing columns and skips empty results", {
  bound <- transitmattr:::.tm_bind_rows(list(
    data.frame(a = 1, b = "x"), list(), data.frame(a = 2)
  ))
  expect_equal(bound$a, c(1, 2))
  expect_equal(bound$b, c("x", NA))
  expect_equal(transitmattr:::.tm_bind_rows(list(list(), list())), data.frame())
})

test_that("$headways() over a date range fetches and binds every day", {
  urls <- record_requests(function(url) {
    day <- regmatches(url, regexpr("2024-01-1[0-9]", url))
    # The last day lacks the optional benchmark column.
    benchmark <- if (day == "2024-01-17") "" else ', "benchmark_headway_time_sec": 300'
    sprintf('[{"route_id": "Red", "direction": "1", "current_dep_dt": "%sT06:00:00",
              "headway_time_sec": 360%s}]', day, benchmark)
  })
  result <- tm_rt_query("Red")$stop("Davis")$direction("southbound")$
    date_range("2024-01-15", "2024-01-17")$headways()
  expect_length(urls(), 3)
  expect_equal(nrow(result), 3)
  expect_equal(format(result$current_dep_dt, "%Y-%m-%d"),
               c("2024-01-15", "2024-01-16", "2024-01-17"))
  expect_equal(result$direction, c(1L, 1L, 1L))
  expect_equal(result$benchmark_headway_time_sec, c(300, 300, NA))
})

test_that("a single date takes precedence over the date range", {
  urls <- record_requests()
  q <- tm_bus_query("1")$stop("Harvard")$date_range("2024-01-01", "2024-01-31")
  q$dwells("2024-01-15")
  q$headways()
  expect_length(urls(), 2)
  expect_true(all(grepl("2024-01-15", urls())))
})

test_that("per-day methods need a date or a date range", {
  expect_error(tm_ferry_query("Boat-F1")$stop("Hull")$headways(),
               "requires a date -- call \\$date\\(\\) or \\$date_range\\(\\)")
})

test_that("$travel_times() over a date range sends one request per day", {
  urls <- record_requests()
  result <- tm_cr_query("CR-Fairmount")$from_stop("Fairmount")$to_stop("Newmarket")$
    direction("inbound")$date_range("2024-01-15", "2024-01-16")$travel_times()
  expect_length(urls(), 2)
  expect_equal(result, data.frame())
})

test_that("RT $trip_metrics() splits long ranges and drops repeated dates", {
  urls <- record_requests(function(url) {
    start <- sub(".*start_date=([0-9-]+).*", "\\1", url)
    # Each span repeats the previous span's last day, to check de-duplication.
    sprintf('[{"date": "%s", "line": "line-red", "count": 1},
              {"date": "2024-05-29", "line": "line-red", "count": 2}]', start)
  })
  result <- tm_rt_query("Red")$date_range("2024-01-01", "2024-12-31")$trip_metrics("daily")
  expect_length(urls(), 3)
  expect_match(urls()[2], "start_date=2024-05-30&end_date=2024-10-26")
  expect_s3_class(result$date, "Date")
  expect_false(anyDuplicated(result$date) > 0)
})

test_that("bus $trip_metrics() spans start on Mondays for weekly", {
  urls <- record_requests()
  tm_bus_query("1")$date_range("2020-01-01", "2024-12-31")$trip_metrics("weekly")
  starts <- as.Date(sub(".*start_date=([0-9-]+).*", "\\1", urls()))
  expect_true(length(starts) > 1)
  expect_true(all(format(starts[-1], "%u") == "1"))
})

test_that("tm_alerts() with end_date returns every day's alerts", {
  urls <- record_requests(function(url) {
    day <- regmatches(url, regexpr("2024-01-1[0-9]", url))
    sprintf('[{"valid_from": "%sT05:00:00-05:00", "valid_to": null, "text": "%s"}]', day, day)
  })
  alerts <- tm_alerts("2024-01-15", route = "Red", end_date = "2024-01-16")
  expect_length(urls(), 2)
  expect_equal(vapply(alerts, `[[`, "", "text"), c("2024-01-15", "2024-01-16"))
  expect_s3_class(alerts[[2]]$valid_from, "POSIXct")
})
