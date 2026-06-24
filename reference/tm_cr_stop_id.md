# Look up stop IDs for a commuter rail station

Terminus stations in one direction may return `character(0)` — this is
normal (the line only serves that stop in one direction).

## Usage

``` r
tm_cr_stop_id(route, stop_name, direction)
```

## Arguments

- route:

  CR route ID, e.g. `"CR-Fairmount"`, `"CR-Lowell"`. Use
  [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md)
  to see all valid route IDs.

- stop_name:

  Station name (case-insensitive). Use
  [`tm_cr_stations()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_stations.md)
  to see valid names for a route.

- direction:

  `"outbound"`, `"inbound"`, `0`, or `1`.

## Value

A character vector of stop IDs (may be empty at some termini).

## Examples

``` r
tm_cr_stop_id("CR-Fairmount", "Fairmount", "outbound")
#> [1] "CR-Fairmount_0_DB-2205-01" "CR-Fairmount_0_DB-2205-02"
tm_cr_stop_id("CR-Fairmount", "South Station", "inbound")
#> character(0)
```
