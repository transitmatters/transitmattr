mock_response <- function(json, status = 200L) {
  httr2::response(
    status_code = status,
    headers     = list("Content-Type" = "application/json"),
    body        = charToRaw(json)
  )
}
