# Get MBTA service alerts

When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
returning current alerts. Pass a date to retrieve alerts for a specific
day.

## Usage

``` r
tm_alerts(user_date = NULL, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object, a `"YYYY-MM-DD"` string, or `NULL` (default) for
  current alerts.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with an `alerts` element.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_alerts()
tm_alerts("2024-01-15")
} # }
```
