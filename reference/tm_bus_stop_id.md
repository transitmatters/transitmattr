# Look up stop IDs for a bus route station

Look up stop IDs for a bus route station

## Usage

``` r
tm_bus_stop_id(route, stop_name, direction)
```

## Arguments

- route:

  Bus route ID, e.g. `"1"`, `"66"`, `"CT2"`, `"SL1"`. Use
  [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md)
  to see all valid route IDs.

- stop_name:

  Station name (case-insensitive). Use
  [`tm_bus_stations()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_stations.md)
  to see valid names for a route.

- direction:

  `"outbound"`, `"inbound"`, `0`, or `1`.

## Value

A character vector of stop IDs.

## Examples

``` r
tm_bus_stop_id("1", "Harvard", "inbound")
#> [1] "1-1-110"
tm_bus_stop_id("66", "Harvard Square", "outbound")
#> Error in .tm_find_station(rd, stop_name): Station 'Harvard Square' not found. Use tm_line_stations() to see valid station names.
```
