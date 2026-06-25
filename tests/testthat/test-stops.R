# -- Rapid transit ---------------------------------------------------------------

test_that("tm_rt_query rejects unknown lines", {
  expect_error(tm_rt_query("Purple"), "Unknown line")
})

test_that("tm_rt_query accepts line variants", {
  expect_no_error(tm_rt_query("red"))
  expect_no_error(tm_rt_query("line-Red"))
  expect_no_error(tm_rt_query("line-red"))
})

test_that("$stations() returns correct data.frame for Red Line", {
  df <- tm_rt_query("Red")$stations()
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order", "branches") %in% names(df)))
  expect_true(nrow(df) > 0)
  expect_true("Alewife" %in% df$stop_name)
  expect_true("place-alfcl" %in% df$station)
})

test_that("$stations() works for all RT lines", {
  for (line in c("Red", "Orange", "Blue", "Green", "Mattapan")) {
    df <- tm_rt_query(line)$stations()
    expect_s3_class(df, "data.frame")
    expect_true(nrow(df) > 0, label = paste("nrow > 0 for", line))
  }
})

test_that("$directions() returns named character vector", {
  dirs <- tm_rt_query("Red")$directions()
  expect_type(dirs, "character")
  expect_equal(dirs[["0"]], "northbound")
  expect_equal(dirs[["1"]], "southbound")
})

test_that("$directions() returns eastbound/westbound for Green", {
  dirs <- tm_rt_query("Green")$directions()
  expect_equal(dirs[["0"]], "eastbound")
  expect_equal(dirs[["1"]], "westbound")
})

test_that("$stop() rejects unknown station names", {
  expect_error(tm_rt_query("Red")$stop("Atlantis"), "not found")
})

test_that("$stop() is case-insensitive", {
  expect_no_error(tm_rt_query("Red")$stop("alewife"))
  expect_no_error(tm_rt_query("Red")$stop("DAVIS"))
})

test_that("$direction() rejects invalid directions for line", {
  expect_error(tm_rt_query("Red")$direction("inbound"), "Unknown direction")
  expect_error(tm_rt_query("Red")$direction("eastbound"), "Unknown direction")
})

test_that("$direction() accepts numeric 0/1", {
  expect_no_error(tm_rt_query("Red")$direction(0))
  expect_no_error(tm_rt_query("Red")$direction(1))
  expect_no_error(tm_rt_query("Red")$direction("0"))
  expect_no_error(tm_rt_query("Red")$direction("1"))
})

test_that("builder methods return self for chaining", {
  q <- tm_rt_query("Red")
  expect_identical(q$stop("Alewife"), q)
  expect_identical(q$direction("southbound"), q)
  expect_identical(q$date("2024-01-15"), q)
  expect_identical(q$date_range("2024-01-01", "2024-01-31"), q)
})

# -- Bus -----------------------------------------------------------------------

test_that("tm_bus_routes() returns a sorted character vector", {
  routes <- tm_bus_routes()
  expect_type(routes, "character")
  expect_true(length(routes) > 100)
  expect_true("1" %in% routes)
  expect_equal(routes, sort(routes))
})

test_that("tm_bus_query rejects unknown routes", {
  expect_error(tm_bus_query("999999"), "Unknown bus route")
})

test_that("$stations() returns correct data.frame for bus route", {
  df <- tm_bus_query("1")$stations()
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order") %in% names(df)))
  expect_true(nrow(df) > 0)
  expect_true("Harvard" %in% df$stop_name)
})

test_that("$stop() is case-insensitive for bus", {
  expect_no_error(tm_bus_query("1")$stop("harvard"))
})

test_that("$stop() rejects invalid bus stop name", {
  expect_error(tm_bus_query("1")$stop("Nowhere"), "not found")
})

# -- Commuter Rail -------------------------------------------------------------

test_that("tm_cr_routes() returns a sorted character vector", {
  routes <- tm_cr_routes()
  expect_type(routes, "character")
  expect_true("CR-Fairmount" %in% routes)
  expect_equal(routes, sort(routes))
})

test_that("tm_cr_query rejects unknown routes", {
  expect_error(tm_cr_query("CR-Narnia"), "Unknown commuter rail route")
})

test_that("$stations() for CR includes terminus column", {
  df <- tm_cr_query("CR-Fairmount")$stations()
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order", "terminus") %in% names(df)))
  expect_true("South Station" %in% df$stop_name)
  expect_true(df$terminus[df$stop_name == "South Station"])
})

test_that("$stop() on a CR terminus emits a warning", {
  expect_warning(
    tm_cr_query("CR-Fairmount")$stop("South Station"),
    "terminus"
  )
})

test_that("$stop() on a non-terminus CR station does not warn", {
  expect_no_warning(tm_cr_query("CR-Fairmount")$stop("Fairmount"))
})

# -- Ferry ---------------------------------------------------------------------

test_that("tm_ferry_routes() returns a sorted character vector", {
  routes <- tm_ferry_routes()
  expect_type(routes, "character")
  expect_true("Boat-F1" %in% routes)
  expect_equal(routes, sort(routes))
})

test_that("tm_ferry_query rejects unknown routes", {
  expect_error(tm_ferry_query("Boat-F99"), "Unknown ferry route")
})

test_that("$stations() for ferry includes terminus column", {
  df <- tm_ferry_query("Boat-F1")$stations()
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order", "terminus") %in% names(df)))
  expect_true("Hingham" %in% df$stop_name)
  expect_true(df$terminus[df$stop_name == "Hingham"])
})

test_that("$stop() on a ferry terminus emits a warning", {
  expect_warning(
    tm_ferry_query("Boat-F1")$stop("Hingham"),
    "terminus"
  )
})
