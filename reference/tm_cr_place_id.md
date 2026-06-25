# Look up the GTFS place ID for a commuter rail station

Returns the GTFS parent-station identifier (e.g. `"place-sstat"`). These
are provided for cross-referencing with the MBTA v3 API. The
TransitMatters aggregate endpoints expect stop IDs from
[`tm_cr_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_stop_id.md),
not place IDs.

## Usage

``` r
tm_cr_place_id(route, stop_name)
```

## Arguments

- route:

  CR route ID. Use
  [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md)
  to see all valid IDs.

- stop_name:

  Station name (case-insensitive).

## Value

A single GTFS place ID string (e.g. `"place-sstat"`).

## Examples

``` r
tm_cr_place_id("CR-Fairmount", "South Station")
#> [1] "place-sstat"
tm_cr_place_id("CR-Fairmount", "Fairmount")
#> [1] "place-DB-2205"
```
