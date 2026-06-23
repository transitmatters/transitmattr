#' @keywords internal
#' @import httr2
"_PACKAGE"

#' @noRd
tm_base_url <- function() {
  getOption(
    "tm_dashboard_base_url",
    "https://dashboard-api.labs.transitmatters.org"
  )
}

#' @noRd
.tm_date <- function(x) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "Date")) format(x, "%Y-%m-%d") else as.character(x)
}

#' @noRd
tm_request <- function(path, query = list(), base_url = tm_base_url()) {
  query <- Filter(Negate(is.null), query)

  req <- request(base_url)
  req <- do.call(req_url_path_append, c(list(req), as.list(path)))
  req <- req_user_agent(req, "transitmattr/0.1.0")
  req <- req_retry(req, max_tries = 3)
  req <- req_error(req, body = function(resp) resp_body_string(resp))

  if (length(query)) {
    req <- do.call(req_url_query, c(list(req), query))
  }

  resp <- req_perform(req)
  resp_body_json(resp, simplifyVector = FALSE)
}
