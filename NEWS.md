# transitmattr 0.2.0

## Breaking changes

* All mode-specific data functions (`tm_headways()`, `tm_dwells()`,
  `tm_travel_times()`, `tm_ridership()`, `tm_trip_metrics()`,
  `tm_line_delays()`, `tm_service_hours()`, `tm_speed_restrictions()`,
  `tm_aggregate_headways()`, `tm_aggregate_dwells()`,
  `tm_aggregate_travel_times()`, `tm_aggregate_travel_times2()`) have been
  removed. Use the new query builder interface instead (see below).

* `tm_time_predictions()` now requires a `route_id` argument.

* All data-fetching functions previously returned a list of records. Query
  builder terminal methods now return a `data.frame` directly, so
  `bind_rows()` or `do.call(rbind, ...)` conversions are no longer needed.

## New query builder interface

Data is now fetched through mode-specific R6 query objects. Each object is
created with a constructor, configured by chaining builder methods, and
activated by a terminal method:

* `tm_rt_query(line)` — rapid transit (Red, Orange, Blue, Green, Mattapan)
* `tm_bus_query(route)` — bus routes
* `tm_cr_query(route)` — commuter rail routes
* `tm_ferry_query(route)` — ferry routes

**Builder methods** (return the object invisibly for chaining):
`$stop()`, `$from_stop()`, `$to_stop()`, `$direction()`, `$date()`,
`$date_range()`

**Discovery methods**: `$stations()` and `$directions()` return data frames
of available stops/directions without hitting the data API.

**Terminal methods** (return a `data.frame`): `$headways()`, `$dwells()`,
`$travel_times()`, `$aggregate_headways()`, `$aggregate_dwells()`,
`$aggregate_travel_times()`, `$ridership()`, `$trip_metrics()`,
`$line_delays()`, `$service_hours()`, `$scheduled_service()`,
`$speed_restrictions()`

Commuter rail and ferry terminus stations now emit a warning when selected via
`$stop()`, `$from_stop()`, or `$to_stop()`, as stop IDs may be missing in one
direction.

## New functions

* `tm_bus_routes()` — returns a sorted character vector of all supported bus
  route IDs (local lookup, no API call).
* `tm_cr_routes()` — same for commuter rail routes.
* `tm_ferry_routes()` — same for ferry routes.

# transitmattr 0.1.0

* Initial CRAN release.
