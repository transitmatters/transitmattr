# Create a commuter rail query

Constructs a `TmCRQuery` object for the given MBTA commuter rail route.
Calling `$stop()` on a terminus station will issue a warning because
stop IDs are often missing in one direction at termini, making
headway/dwell data potentially incomplete.

## Usage

``` r
tm_cr_query(route, base_url = tm_base_url())
```

## Arguments

- route:

  CR route ID, e.g. `"CR-Fairmount"`, `"CR-Lowell"`. Use
  [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md)
  to see all valid route IDs.

- base_url:

  API base URL. Defaults to the production host or the
  `tm_dashboard_base_url` option.

## Value

A `TmCRQuery` R6 object.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_cr_query("CR-Fairmount")$stop("Fairmount")$headways("2024-01-15")

# Terminus warning is emitted here:
tm_cr_query("CR-Fitchburg")$stop("Wachusett")$headways("2024-01-15")
} # }
```
