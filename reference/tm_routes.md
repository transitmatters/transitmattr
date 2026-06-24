# List all available routes

List all available routes

## Usage

``` r
tm_routes(base_url = tm_base_url())
```

## Arguments

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with elements `rapid_transit`, `bus`, `commuter_rail`, and
`ferry`, each containing the routes available in that category.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_routes()
} # }
```
