# Get the service ridership dashboard summary

Get the service ridership dashboard summary

## Usage

``` r
tm_service_ridership_dashboard(base_url = tm_base_url())
```

## Arguments

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list containing the service ridership dashboard data.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_service_ridership_dashboard()
} # }
```
