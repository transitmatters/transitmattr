#' Base query class (internal)
#'
#' Holds shared date state and validation helpers inherited by all mode-specific
#' query classes. Do not instantiate directly -- use [tm_rt_query()],
#' [tm_bus_query()], [tm_cr_query()], or [tm_ferry_query()].
#' @noRd
TmBaseQuery <- R6Class("TmBaseQuery",
  cloneable = FALSE,
  private = list(
    .base_url    = NULL,
    .date        = NULL,
    .start_date  = NULL,
    .end_date    = NULL,

    .assert_date = function(method) {
      if (is.null(private$.date))
        stop(method, " requires a date -- call $date() first.", call. = FALSE)
    },
    .assert_date_range = function(method) {
      if (is.null(private$.start_date) || is.null(private$.end_date))
        stop(method, " requires a date range -- call $date_range() first.",
             call. = FALSE)
    },

    # Call tm_request with simplifyVector = TRUE and return a data.frame.
    # Returns an empty data.frame when the API returns an empty array.
    .get = function(path, query = list()) {
      result <- tm_request(path, query = query, base_url = private$.base_url,
                           simplify = TRUE)
      if (is.data.frame(result)) result else data.frame()
    }
  ),
  public = list(
    #' @description
    #' Create a new query object.
    #' @param base_url API base URL; defaults to the production host or the
    #'   `tm_dashboard_base_url` option.
    initialize = function(base_url = tm_base_url()) {
      private$.base_url <- base_url
    },

    #' @description Set a single query date.
    #' @param d A `Date` object or a `"YYYY-MM-DD"` string.
    #' @return `self` (invisibly), for chaining.
    date = function(d) {
      private$.date <- .tm_date(d)
      invisible(self)
    },

    #' @description Set a date range for aggregate or multi-day queries.
    #' @param start Start date (`Date` or `"YYYY-MM-DD"`).
    #' @param end End date (`Date` or `"YYYY-MM-DD"`).
    #' @return `self` (invisibly), for chaining.
    date_range = function(start, end) {
      private$.start_date <- .tm_date(start)
      private$.end_date   <- .tm_date(end)
      invisible(self)
    }
  )
)
