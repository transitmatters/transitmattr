# Look up stop IDs for a ferry station

Look up stop IDs for a ferry station

## Usage

``` r
tm_ferry_stop_id(route, stop_name, direction)
```

## Arguments

- route:

  Ferry route ID, e.g. `"Boat-F1"`, `"Boat-F4"`. Use
  [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md)
  to see all valid route IDs.

- stop_name:

  Station name (case-insensitive). Use
  [`tm_ferry_stations()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_stations.md)
  to see valid names for a route.

- direction:

  `"outbound"`, `"inbound"`, `0`, or `1`.

## Value

A character vector of stop IDs.

## Examples

``` r
tm_ferry_stop_id("Boat-F1", "Hingham", "inbound")
#> [1] "Boat-F1|1|Boat-Hingham"
tm_ferry_stop_id("Boat-F1", "Long Wharf (North)", "outbound")
#> [1] "Boat-F1|0|Boat-Long"
```
