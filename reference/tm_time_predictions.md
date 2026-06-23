# Get current time predictions

Get current time predictions

## Usage

``` r
tm_time_predictions(base_url = tm_base_url())
```

## Arguments

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of time prediction objects.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_time_predictions()
} # }
```
