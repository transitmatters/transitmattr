# Get stops for a route

Get stops for a route

## Usage

``` r
tm_stops(route_id, base_url = tm_base_url())
```

## Arguments

- route_id:

  An MBTA route ID string (e.g. `"Red"`, `"Orange"`, `"Green-B"`,
  `"CR-Fairmount"`). Use
  [`tm_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_routes.md)
  to list all valid IDs.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with `type`, `direction`, and `stations` elements.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_stops("Red")
tm_stops("Green-B")
} # }
```
