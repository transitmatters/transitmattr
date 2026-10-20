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

    # The service dates for a per-day method: `date` if given (it also becomes
    # the query's date), else the query's date, else every day in its range.
    .dates = function(method, date = NULL) {
      if (!is.null(date)) private$.date <- .tm_date(date)
      if (!is.null(private$.date)) return(private$.date)
      if (!is.null(private$.start_date) && !is.null(private$.end_date)) {
        return(.tm_days(private$.start_date, private$.end_date))
      }
      stop(method, " requires a date -- call $date() or $date_range() first.",
           call. = FALSE)
    },

    # Call a generated API operation (see .tm_call()) with simplifyVector =
    # TRUE and return a data.frame. Returns an empty data.frame when the API
    # returns an empty array.
    .get = function(operation, ...) {
      .tm_data_frame(.tm_call(operation, ..., base_url = private$.base_url,
                              simplify = TRUE))
    },

    # Like .get(), for a per-day operation: one request per date in `dates`,
    # sent in parallel, with the results in one data.frame.
    .get_each = function(operation, dates, ...) {
      varying <- lapply(dates, function(d) list(user_date = d))
      .tm_data_frame(.tm_call_each(operation, varying, ...,
                                   base_url = private$.base_url,
                                   simplify = TRUE))
    },

    # Like .get(), for a trip metrics operation over the query's date range,
    # split into spans short enough for the API at aggregation level
    # `span_agg` (see .tm_spans()).
    .get_spans = function(operation, span_agg, ...) {
      spans <- .tm_spans(private$.start_date, private$.end_date, span_agg)
      varying <- lapply(spans, function(span) {
        list(start_date = format(span[[1]]), end_date = format(span[[2]]))
      })
      result <- .tm_data_frame(.tm_call_each(operation, varying, ...,
                                             base_url = private$.base_url,
                                             simplify = TRUE))
      # Spans break at period boundaries, so a period shouldn't come back
      # twice; drop repeats in case one does.
      if (length(spans) > 1 && "date" %in% names(result)) {
        result <- result[!duplicated(result$date), , drop = FALSE]
        rownames(result) <- NULL
      }
      result
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
    #'   Per-day methods such as `$headways()` fetch every day in the range
    #'   when no single date is set.
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
