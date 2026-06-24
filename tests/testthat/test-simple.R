test_that("tm_healthcheck returns status field", {
  httr2::local_mocked_responses(
    function(req) mock_response('{"status":"pass"}')
  )
  result <- tm_healthcheck()
  expect_equal(result$status, "pass")
})

test_that("tm_facilities returns a list", {
  httr2::local_mocked_responses(
    function(req) mock_response('[{"id":"f1","name":"Park Street"}]')
  )
  result <- tm_facilities()
  expect_type(result, "list")
})

test_that("tm_service_ridership_dashboard returns a list", {
  httr2::local_mocked_responses(
    function(req) mock_response('{"data":{}}')
  )
  result <- tm_service_ridership_dashboard()
  expect_type(result, "list")
})
