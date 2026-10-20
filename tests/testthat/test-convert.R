# Tests for R/convert.R, which converts parsed responses to R types.

ns <- asNamespace("transitmattr")
conversions <- transitmattr:::.tm_conversions

# A generated model's fields: its public fields are named as in the JSON,
# plus `_field_list` and `additional_properties` in models that allow extra
# properties.
model_fields <- function(name) {
  generator <- get0(name, envir = ns)
  not_models <- c("ApiApi", "ApiClient", "ApiResponse", "TmRequestBuilder")
  if (!inherits(generator, "R6ClassGenerator") || name %in% not_models) {
    return(NULL)
  }
  setdiff(names(generator$public_fields),
          c("_field_list", "additional_properties"))
}

# Leaves out request parameters, error bodies, and the wrappers the generator
# makes for anyOf schemas.
response_models <- Filter(function(name) {
  fields <- model_fields(name)
  !is.null(fields) && !"actual_instance" %in% fields &&
    !endsWith(name, "Params") &&
    !name %in% c("ErrorResponse", "RouteNotFoundResponse")
}, sort(ls(ns)))

test_that("every converted model and field exists in the generated code", {
  for (model in names(conversions)) {
    fields <- model_fields(model)
    expect_false(is.null(fields), label = paste("model", model))
    for (field in names(conversions[[model]])) {
      expect_true(field %in% fields, label = paste0(model, "$", field))
      type <- sub("^map:", "", conversions[[model]][[field]])
      if (!type %in% names(transitmattr:::.tm_parsers)) {
        expect_false(is.null(model_fields(type)), label = paste(model, "->", type))
      }
    }
  }
})

test_that("every operation's response model is a generated model", {
  for (operation in names(transitmattr:::.tm_wrapped_ops)) {
    model <- transitmattr:::.tm_response_model(operation)
    expect_true(model %in% response_models, label = paste(operation, "->", model))
  }
})

test_that("the response models' fields haven't changed", {
  # Fails when a spec sync adds, removes, or renames a field. Check whether
  # .tm_conversions in R/convert.R needs an entry for it, then run
  # testthat::snapshot_accept("convert").
  expect_snapshot(
    for (model in response_models) {
      cat(model, ": ", paste(model_fields(model), collapse = ", "), "\n", sep = "")
    }
  )
})

# Parsers ---------------------------------------------------------------------

test_that("times without an offset are Eastern wall-clock times", {
  x <- transitmattr:::.tm_as_datetime(c("2024-01-15T05:27:12", "2024-07-04T23:59:59", NA))
  expect_s3_class(x, "POSIXct")
  expect_equal(attr(x, "tzone"), "America/New_York")
  expect_equal(format(x[1:2], "%Y-%m-%d %H:%M:%S %Z"),
               c("2024-01-15 05:27:12 EST", "2024-07-04 23:59:59 EDT"))
  expect_true(is.na(x[3]))
})

test_that("times with an offset are converted to Eastern time", {
  x <- transitmattr:::.tm_as_datetime(c("2024-01-15T05:58:00-05:00",
                                        "2024-01-15T12:00:00+00:00"))
  expect_equal(format(x, "%H:%M"), c("05:58", "07:00"))
})

test_that("times without seconds parse", {
  x <- transitmattr:::.tm_as_datetime("2026-10-01T14:00")
  expect_equal(format(x, "%Y-%m-%d %H:%M:%S"), "2026-10-01 14:00:00")
})

test_that("times of day become hms", {
  x <- transitmattr:::.tm_parsers$time_of_day(c("1970-01-01T05:30:00", "1970-01-01T23:00:00"))
  expect_s3_class(x, "hms")
  expect_equal(as.numeric(x), c(5.5, 23) * 3600)
})

test_that("conversion walks data frames, nested data frames, and lists", {
  df <- data.frame(date = c("2025-01-01", "2025-02-01"), days = c(14L, 10L))
  df$peak <- data.frame(otpNumerator = 1:2)
  converted <- transitmattr:::.tm_convert(df, "ReliabilityEntry")
  expect_equal(converted$date, as.Date(c("2025-01-01", "2025-02-01")))
  expect_equal(converted$days, c(14L, 10L))

  alerts <- list(list(
    id = "1", stops = list(1587, "place-pktrm"),
    active_period = list(list(start = "2026-11-08T07:30:00-05:00", end = NULL))
  ))
  converted <- transitmattr:::.tm_convert(alerts, "LiveAlert")[[1]]
  expect_equal(converted$stops, list("1587", "place-pktrm"))
  expect_s3_class(converted$active_period[[1]]$start, "POSIXct")
  # A null field stays NULL rather than disappearing.
  expect_true("end" %in% names(converted$active_period[[1]]))

  dashboard <- list(lineData = list(`line-Red` = list(startDate = "2016-01-04")))
  converted <- transitmattr:::.tm_convert(dashboard, "ServiceRidershipDashboardResponse")
  expect_equal(converted$lineData$`line-Red`$startDate, as.Date("2016-01-04"))
})

test_that("values that don't parse are left alone with a warning", {
  df <- data.frame(date = c("2025-01-01", "last week"))
  expect_warning(
    converted <- transitmattr:::.tm_convert(df, "RidershipEntry"),
    "RidershipEntry\\$date"
  )
  expect_equal(converted$date, c("2025-01-01", "last week"))
})
