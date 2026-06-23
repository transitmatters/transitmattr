test_that(".tm_date handles Date objects", {
  expect_equal(transitmattr:::.tm_date(as.Date("2024-01-15")), "2024-01-15")
})

test_that(".tm_date handles strings unchanged", {
  expect_equal(transitmattr:::.tm_date("2024-01-15"), "2024-01-15")
})

test_that(".tm_date returns NULL for NULL", {
  expect_null(transitmattr:::.tm_date(NULL))
})

test_that("tm_base_url returns default host", {
  withr::with_options(list(tm_dashboard_base_url = NULL), {
    expect_equal(
      transitmattr:::tm_base_url(),
      "https://dashboard-api.labs.transitmatters.org"
    )
  })
})

test_that("tm_base_url respects option override", {
  withr::with_options(list(tm_dashboard_base_url = "https://staging.example.com"), {
    expect_equal(transitmattr:::tm_base_url(), "https://staging.example.com")
  })
})
