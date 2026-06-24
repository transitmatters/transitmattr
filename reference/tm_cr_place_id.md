# Look up the GTFS place ID for a commuter rail station

Look up the GTFS place ID for a commuter rail station

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
