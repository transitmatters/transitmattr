# Get current time predictions

Returns time prediction accuracy data for an MBTA route.

## Usage

``` r
tm_time_predictions(route_id, base_url = tm_base_url())
```

## Arguments

- route_id:

  Route identifier, e.g. `"Red"`, `"CR-Fairmount"`.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with a `predictions` field.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_time_predictions("Red")
} # }
```
