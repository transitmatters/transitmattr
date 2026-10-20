# Changelog

## transitmattr 0.3.0

### Breaking changes

- `tm_git_id()` has been removed. The API no longer has a `/api/git_id`
  endpoint.

- [`tm_scheduled_service()`](https://transitmatters.github.io/transitmattr/reference/tm_scheduled_service.md)
  now requires `route_id`, as the API does.

- Results have R types instead of the API’s strings: times are `POSIXct`
  date-times in Eastern time (`America/New_York`), dates are `Date`s,
  and the time of day in `$aggregate_travel_times_v2()`‘s `by_time` is
  an `hms`. Headway `direction` is an integer, like the other events’.
  Column names are unchanged. Code that parsed these columns itself,
  e.g. with [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html) or
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html), still works but no
  longer needs to.

- Errors have transitmattr’s own classes, such as
  `transitmattr_not_found` and `transitmattr_range_too_long` (see
  [`?transitmattr_errors`](https://transitmatters.github.io/transitmattr/reference/transitmattr_errors.md)),
  and their messages include the API’s explanation. They keep httr2’s
  `httr2_http_<status>` classes too.

- A 500 response is no longer retried; the API also sends one for bad
  requests.

### New features

- New endpoints:

  - `tm_bus_query(route)$trip_metrics()`: trips delivered, miles, and
    speeds for a bus route, optionally for one `time_band` or
    `day_type`.
  - `tm_cr_query(route)$trip_metrics()`: commuter rail fleet mix.
  - `tm_cr_query(route)$reliability()` and
    [`tm_reliability()`](https://transitmatters.github.io/transitmattr/reference/tm_reliability.md):
    on-time performance for commuter rail or The RIDE.
  - `tm_cr_query(route)$scorecard()`: a commuter rail schedule measured
    against Regional Rail standards.
  - [`tm_bus_speed_leaderboard()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_speed_leaderboard.md):
    the slowest bus routes over a date range.
  - [`tm_weather()`](https://transitmatters.github.io/transitmattr/reference/tm_weather.md):
    hourly weather in downtown Boston.
  - `$aggregate_travel_times_v2()` on rapid transit and commuter rail
    queries: travel time statistics by date and by time of day.

- `$headways()`, `$dwells()`, and `$travel_times()` fetch every day in
  `$date_range()` when no single date is set, several days at a time,
  and return one data frame.
  [`tm_alerts()`](https://transitmatters.github.io/transitmattr/reference/tm_alerts.md)
  takes an `end_date`. Set `options(transitmattr.max_concurrency = n)`
  to change how many requests are in flight at once (default 8).

- The `$trip_metrics()` methods accept ranges longer than the API’s
  limit of 150 days, weeks, or months, by fetching them in pieces.

- Requests that time out, fail to connect, or get a 429, 502, 503, or
  504 are retried up to three times with exponential backoff, waiting as
  long as a `Retry-After` header asks.

- `agg` arguments accept `"monthly"` wherever the API does
  (`$trip_metrics()`, `$service_hours()`, `$scheduled_service()`), and
  values the API doesn’t accept are rejected before a request is sent.

### Bug fixes

- `tm_rt_query(line)$scheduled_service()` returned an empty data frame.
  It now returns the same list as
  [`tm_scheduled_service()`](https://transitmatters.github.io/transitmattr/reference/tm_scheduled_service.md).

- [`tm_healthcheck()`](https://transitmatters.github.io/transitmattr/reference/tm_healthcheck.md)
  returns the failing checks when the API reports a failure, instead of
  raising an HTTP 500 error.

- [`tm_stops()`](https://transitmatters.github.io/transitmattr/reference/tm_stops.md)
  percent-encodes route IDs, so combined bus routes such as `"SL4/SL5"`
  work.

### Internals

- Requests now go through a client generated from the API’s OpenAPI spec
  with OpenAPI Generator (`R/generated-*.R`). The spec is pinned in
  `spec/openapi.json`; a weekly GitHub Actions workflow syncs it from
  upstream, regenerates the client, and opens a pull request.

- The user agent now reports the installed package version.

- DESCRIPTION now requires R 4.1 and httr2 1.1.1, which the package
  already needed: httr2 requires R 4.1, and parallel requests need httr2
  1.1.1.

- A test keeps a snapshot of every response model’s fields, so a spec
  sync that adds, removes, or renames a field fails until someone checks
  whether `.tm_conversions` in `R/convert.R` needs updating.

## transitmattr 0.2.0

### Breaking changes

- All mode-specific data functions (`tm_headways()`, `tm_dwells()`,
  `tm_travel_times()`, `tm_ridership()`, `tm_trip_metrics()`,
  `tm_line_delays()`, `tm_service_hours()`, `tm_speed_restrictions()`,
  `tm_aggregate_headways()`, `tm_aggregate_dwells()`,
  `tm_aggregate_travel_times()`, `tm_aggregate_travel_times2()`) have
  been removed. Use the new query builder interface instead (see below).

- [`tm_time_predictions()`](https://transitmatters.github.io/transitmattr/reference/tm_time_predictions.md)
  now requires a `route_id` argument.

- All data-fetching functions previously returned a list of records.
  Query builder terminal methods now return a `data.frame` directly, so
  [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
  or `do.call(rbind, ...)` conversions are no longer needed.

### New query builder interface

Data is now fetched through mode-specific R6 query objects. Each object
is created with a constructor, configured by chaining builder methods,
and activated by a terminal method:

- `tm_rt_query(line)` — rapid transit (Red, Orange, Blue, Green,
  Mattapan)
- `tm_bus_query(route)` — bus routes
- `tm_cr_query(route)` — commuter rail routes
- `tm_ferry_query(route)` — ferry routes

**Builder methods** (return the object invisibly for chaining):
`$stop()`, `$from_stop()`, `$to_stop()`, `$direction()`, `$date()`,
`$date_range()`

**Discovery methods**: `$stations()` and `$directions()` return data
frames of available stops/directions without hitting the data API.

**Terminal methods** (return a `data.frame`): `$headways()`,
`$dwells()`, `$travel_times()`, `$aggregate_headways()`,
`$aggregate_dwells()`, `$aggregate_travel_times()`, `$ridership()`,
`$trip_metrics()`, `$line_delays()`, `$service_hours()`,
`$scheduled_service()`, `$speed_restrictions()`

Commuter rail and ferry terminus stations now emit a warning when
selected via `$stop()`, `$from_stop()`, or `$to_stop()`, as stop IDs may
be missing in one direction.

### New functions

- [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md)
  — returns a sorted character vector of all supported bus route IDs
  (local lookup, no API call).
- [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md)
  — same for commuter rail routes.
- [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md)
  — same for ferry routes.

## transitmattr 0.1.0

- Initial CRAN release.
