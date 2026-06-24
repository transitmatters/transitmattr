#' Get aggregate travel times
#'
#' Retrieves aggregated travel time data over a date range and stop pair.
#' Common query parameters include `from_stop`, `to_stop`, `start_date`, and
#' `end_date`.
#'
#' @param ... Named query parameters passed to the API (e.g., `from_stop`,
#'   `to_stop`, `start_date`, `end_date`).
#' @param base_url Base URL of the TransitMatters API. Defaults to
#'   `getOption("tm_dashboard_base_url")` or the production host.
#' @return A list with a `data` element.
#' @export
#' @examples
#' \dontrun{
#' tm_aggregate_travel_times(
#'   from_stop  = "place-pktrm",
#'   to_stop    = "place-davis",
#'   start_date = "2024-01-01",
#'   end_date   = "2024-01-31"
#' )
#' }
tm_aggregate_travel_times <- function(..., base_url = tm_base_url()) {
  tm_request("api/aggregate/traveltimes", query = list(...), base_url = base_url)
}

#' Get aggregate travel times (v2)
#'
#' Second variant of the aggregate travel times endpoint. Accepts the same
#' query parameters as [tm_aggregate_travel_times()].
#'
#' @inheritParams tm_aggregate_travel_times
#' @return A list with `by_date` and `by_time` elements.
#' @export
#' @examples
#' \dontrun{
#' tm_aggregate_travel_times2(
#'   from_stop  = "place-pktrm",
#'   to_stop    = "place-davis",
#'   start_date = "2024-01-01",
#'   end_date   = "2024-01-31"
#' )
#' }
tm_aggregate_travel_times2 <- function(..., base_url = tm_base_url()) {
  tm_request("api/aggregate/traveltimes2", query = list(...), base_url = base_url)
}

#' Get aggregate headways
#'
#' Common query parameters include `stop`, `start_date`, `end_date`, and
#' `direction_id`.
#'
#' @inheritParams tm_aggregate_travel_times
#' @return A list of aggregated headway data.
#' @export
#' @examples
#' \dontrun{
#' tm_aggregate_headways(
#'   stop       = "70063",
#'   start_date = "2024-01-01",
#'   end_date   = "2024-01-31"
#' )
#' }
tm_aggregate_headways <- function(..., base_url = tm_base_url()) {
  tm_request("api/aggregate/headways", query = list(...), base_url = base_url)
}

#' Get aggregate dwells
#'
#' Common query parameters include `stop`, `start_date`, `end_date`, and
#' `direction_id`.
#'
#' @inheritParams tm_aggregate_travel_times
#' @return A list of aggregated dwell time data.
#' @export
#' @examples
#' \dontrun{
#' tm_aggregate_dwells(
#'   stop       = "70063",
#'   start_date = "2024-01-01",
#'   end_date   = "2024-01-31"
#' )
#' }
tm_aggregate_dwells <- function(..., base_url = tm_base_url()) {
  tm_request("api/aggregate/dwells", query = list(...), base_url = base_url)
}
