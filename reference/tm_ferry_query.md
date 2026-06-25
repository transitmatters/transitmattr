# Create a ferry query

Constructs a `TmFerryQuery` object for the given MBTA ferry route.
Calling `$stop()` on a terminus stop will issue a warning.

## Usage

``` r
tm_ferry_query(route, base_url = tm_base_url())
```

## Arguments

- route:

  Ferry route ID, e.g. `"Boat-F1"`, `"Boat-F4"`. Use
  [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md)
  to see all valid route IDs.

- base_url:

  API base URL. Defaults to the production host or the
  `tm_dashboard_base_url` option.

## Value

A `TmFerryQuery` R6 object.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_ferry_query("Boat-F1")$stop("Hingham")$headways("2024-01-15")
} # }
```
