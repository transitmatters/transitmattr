# Get MBTA service alerts

When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
returning current live alerts. Pass a date to retrieve historical
alerts, optionally filtered by route.

## Usage

``` r
tm_alerts(user_date = NULL, route = NULL, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object, a `"YYYY-MM-DD"` string, or `NULL` (default) for
  current alerts.

- route:

  One or more MBTA route IDs (e.g. `"Red"`, `"Orange"`). Only used when
  `user_date` is provided.

- base_url:

  Base URL of the TransitMatters API.

## Value

A list with an `alerts` element.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_alerts()
tm_alerts("2024-01-15", route = "Red")
} # }
```
