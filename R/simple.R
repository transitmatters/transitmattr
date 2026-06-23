#' Check API health
#'
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with fields `status` (string) and optionally `failed_checks`.
#' @export
#' @examples
#' \dontrun{
#' tm_healthcheck()
#' }
tm_healthcheck <- function(base_url = tm_base_url()) {
  tm_request("api/healthcheck", base_url = base_url)
}

#' Get the deployed git commit ID
#'
#' @inheritParams tm_healthcheck
#' @return A list with the git commit SHA of the running server.
#' @export
#' @examples
#' \dontrun{
#' tm_git_id()
#' }
tm_git_id <- function(base_url = tm_base_url()) {
  tm_request("api/git_id", base_url = base_url)
}

#' List MBTA facilities
#'
#' @inheritParams tm_healthcheck
#' @return A list of facility objects.
#' @export
#' @examples
#' \dontrun{
#' tm_facilities()
#' }
tm_facilities <- function(base_url = tm_base_url()) {
  tm_request("api/facilities", base_url = base_url)
}

#' Get current time predictions
#'
#' @inheritParams tm_healthcheck
#' @return A list of time prediction objects.
#' @export
#' @examples
#' \dontrun{
#' tm_time_predictions()
#' }
tm_time_predictions <- function(base_url = tm_base_url()) {
  tm_request("api/time_predictions", base_url = base_url)
}

#' Get the service ridership dashboard summary
#'
#' @inheritParams tm_healthcheck
#' @return A list containing the service ridership dashboard data.
#' @export
#' @examples
#' \dontrun{
#' tm_service_ridership_dashboard()
#' }
tm_service_ridership_dashboard <- function(base_url = tm_base_url()) {
  tm_request("api/service_ridership_dashboard", base_url = base_url)
}
