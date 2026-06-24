test_that("tm_stop_id returns correct stop IDs for Red Line", {
  expect_equal(tm_stop_id("Red", "Alewife", "southbound"), "70061")
  expect_equal(tm_stop_id("Red", "Alewife", "northbound"), "70061")
  expect_equal(tm_stop_id("Red", "Davis", "northbound"), "70064")
  expect_equal(tm_stop_id("Red", "Davis", "southbound"), "70063")
})

test_that("tm_stop_id accepts direction as 0/1", {
  expect_equal(tm_stop_id("Red", "Davis", 0), "70064")
  expect_equal(tm_stop_id("Red", "Davis", 1), "70063")
  expect_equal(tm_stop_id("Red", "Davis", "0"), "70064")
  expect_equal(tm_stop_id("Red", "Davis", "1"), "70063")
})

test_that("tm_stop_id works for Green Line (eastbound/westbound)", {
  # Green Line uses eastbound/westbound not northbound/southbound
  expect_no_error(tm_stop_id("Green", "Park Street", "eastbound"))
  expect_no_error(tm_stop_id("Green", "Park Street", "westbound"))
})

test_that("tm_stop_id is case-insensitive for line and stop name", {
  expect_equal(tm_stop_id("red", "alewife", "southbound"),
               tm_stop_id("Red", "Alewife", "southbound"))
  expect_equal(tm_stop_id("line-red", "DAVIS", "northbound"),
               tm_stop_id("Red", "Davis", "northbound"))
  expect_equal(tm_stop_id("line-Red", "davis", "Northbound"),
               tm_stop_id("Red", "Davis", "northbound"))
})

test_that("tm_place_id returns correct GTFS place ID", {
  expect_equal(tm_place_id("Red", "Alewife"), "place-alfcl")
  expect_equal(tm_place_id("Red", "Davis"), "place-davis")
  expect_equal(tm_place_id("Orange", "Oak Grove"), "place-ogmnl")
})

test_that("tm_place_id is case-insensitive", {
  expect_equal(tm_place_id("red", "alewife"), "place-alfcl")
  expect_equal(tm_place_id("line-red", "DAVIS"), "place-davis")
})

test_that("tm_line_stations returns a data frame with expected columns", {
  df <- tm_line_stations("Red")
  expect_s3_class(df, "data.frame")
  expected_cols <- c("stop_name", "station", "order", "branches")
  expect_true(all(expected_cols %in% names(df)))
  expect_true(nrow(df) > 0)
  expect_true("Alewife" %in% df$stop_name)
  expect_true("place-alfcl" %in% df$station)
})

test_that("tm_line_stations works for all lines", {
  for (line in c("Red", "Orange", "Blue", "Green", "Mattapan")) {
    df <- tm_line_stations(line)
    expect_s3_class(df, "data.frame")
    expect_true(nrow(df) > 0, label = paste("nrow > 0 for", line))
  }
})

test_that("tm_line_directions returns named character vector", {
  dirs <- tm_line_directions("Red")
  expect_type(dirs, "character")
  expect_equal(dirs[["0"]], "northbound")
  expect_equal(dirs[["1"]], "southbound")
})

test_that("tm_line_directions returns eastbound/westbound for Green", {
  dirs <- tm_line_directions("Green")
  expect_equal(dirs[["0"]], "eastbound")
  expect_equal(dirs[["1"]], "westbound")
})

test_that("errors are informative for bad inputs", {
  expect_error(tm_stop_id("Purple", "Alewife", "northbound"), "Unknown line")
  expect_error(tm_stop_id("Red", "Atlantis", "northbound"), "not found")
  expect_error(tm_stop_id("Red", "Alewife", "inbound"), "Unknown direction")
  expect_error(tm_line_stations("Fuchsia"), "Unknown line")
  expect_error(tm_place_id("Red", "Nowhere"), "not found")
})

# -- Bus -----------------------------------------------------------------------

test_that("tm_bus_stop_id returns correct stop IDs", {
  expect_equal(tm_bus_stop_id("1", "Harvard", "inbound"), "1-1-110")
  expect_equal(tm_bus_stop_id("1", "Harvard", "outbound"), "1-0-110")
  expect_equal(tm_bus_stop_id("1", "Harvard", 1), "1-1-110")
  expect_equal(tm_bus_stop_id("1", "Harvard", 0), "1-0-110")
})

test_that("tm_bus_stop_id is case-insensitive for route and stop name", {
  expect_equal(tm_bus_stop_id("1", "harvard", "inbound"),
               tm_bus_stop_id("1", "Harvard", "inbound"))
})

test_that("tm_bus_stations returns a data frame with expected columns", {
  df <- tm_bus_stations("1")
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order") %in% names(df)))
  expect_true(nrow(df) > 0)
  expect_true("Harvard" %in% df$stop_name)
})

test_that("tm_bus_routes returns a sorted character vector", {
  routes <- tm_bus_routes()
  expect_type(routes, "character")
  expect_true(length(routes) > 100)
  expect_true("1" %in% routes)
  expect_true("66" %in% routes)
  expect_equal(routes, sort(routes))
})

test_that("tm_bus_stop_id errors informatively for bad route", {
  expect_error(tm_bus_stop_id("999999", "Harvard", "inbound"), "Unknown bus route")
})

# -- Commuter Rail -------------------------------------------------------------

test_that("tm_cr_stop_id returns correct stop IDs", {
  expect_equal(
    tm_cr_stop_id("CR-Fairmount", "Fairmount", "outbound"),
    c("CR-Fairmount_0_DB-2205-01", "CR-Fairmount_0_DB-2205-02")
  )
  expect_equal(
    tm_cr_stop_id("CR-Fairmount", "Fairmount", "inbound"),
    "CR-Fairmount_1_DB-2205-02"
  )
})

test_that("tm_cr_stop_id returns character(0) at non-served terminus", {
  result <- tm_cr_stop_id("CR-Fairmount", "Readville", "outbound")
  expect_equal(result, character(0))
})

test_that("tm_cr_stop_id accepts numeric direction", {
  expect_equal(
    tm_cr_stop_id("CR-Fairmount", "Fairmount", 0),
    tm_cr_stop_id("CR-Fairmount", "Fairmount", "outbound")
  )
})

test_that("tm_cr_place_id returns correct GTFS place ID", {
  expect_equal(tm_cr_place_id("CR-Fairmount", "South Station"), "place-sstat")
  expect_equal(tm_cr_place_id("CR-Fairmount", "Fairmount"), "place-DB-2205")
})

test_that("tm_cr_stations returns a data frame with terminus column", {
  df <- tm_cr_stations("CR-Fairmount")
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order", "terminus") %in% names(df)))
  expect_true("South Station" %in% df$stop_name)
  expect_true(df$terminus[df$stop_name == "South Station"])
})

test_that("tm_cr_routes returns a sorted character vector", {
  routes <- tm_cr_routes()
  expect_type(routes, "character")
  expect_true("CR-Fairmount" %in% routes)
  expect_equal(routes, sort(routes))
})

test_that("tm_cr_stop_id errors informatively for bad route", {
  expect_error(tm_cr_stop_id("CR-Narnia", "Fairmount", "outbound"),
               "Unknown commuter rail route")
})

# -- Ferry ---------------------------------------------------------------------

test_that("tm_ferry_stop_id returns correct stop IDs", {
  expect_equal(
    tm_ferry_stop_id("Boat-F1", "Hingham", "inbound"),
    "Boat-F1|1|Boat-Hingham"
  )
  expect_equal(
    tm_ferry_stop_id("Boat-F1", "Hingham", "outbound"),
    "Boat-F1|0|Boat-Hingham"
  )
})

test_that("tm_ferry_stop_id accepts numeric direction", {
  expect_equal(
    tm_ferry_stop_id("Boat-F1", "Hingham", 1),
    tm_ferry_stop_id("Boat-F1", "Hingham", "inbound")
  )
})

test_that("tm_ferry_stations returns a data frame with terminus column", {
  df <- tm_ferry_stations("Boat-F1")
  expect_s3_class(df, "data.frame")
  expect_true(all(c("stop_name", "station", "order", "terminus") %in% names(df)))
  expect_true("Hingham" %in% df$stop_name)
  expect_true(df$terminus[df$stop_name == "Hingham"])
})

test_that("tm_ferry_routes returns a sorted character vector", {
  routes <- tm_ferry_routes()
  expect_type(routes, "character")
  expect_true("Boat-F1" %in% routes)
  expect_equal(routes, sort(routes))
})

test_that("tm_ferry_stop_id errors informatively for bad route", {
  expect_error(tm_ferry_stop_id("Boat-F99", "Hingham", "inbound"),
               "Unknown ferry route")
})
