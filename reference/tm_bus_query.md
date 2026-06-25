# Create a bus query

Constructs a `TmBusQuery` object for the given MBTA bus route.

## Usage

``` r
tm_bus_query(route, base_url = tm_base_url())
```

## Arguments

- route:

  Bus route ID, e.g. `"1"`, `"66"`, `"CT2"`, `"SL1"`. Use
  [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md)
  to see all valid route IDs.

- base_url:

  API base URL. Defaults to the production host or the
  `tm_dashboard_base_url` option.

## Value

A `TmBusQuery` R6 object.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_bus_query("1")$stop("Harvard")$headways("2024-01-15")
tm_bus_query("66")$stop("Harvard")$direction("inbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
} # }
```
