# Get MBTA service alerts

When `user_date` is `NULL` the undated `/api/alerts` endpoint is called,
returning current live alerts. Pass a date to retrieve historical
alerts, optionally filtered by route, and an `end_date` to retrieve them
for every day from `user_date` through `end_date`.

## Usage

``` r
tm_alerts(
  user_date = NULL,
  route = NULL,
  end_date = NULL,
  base_url = tm_base_url()
)
```

## Arguments

- user_date:

  A `Date` object, a `"YYYY-MM-DD"` string, or `NULL` (default) for
  current alerts.

- route:

  One or more MBTA route IDs (e.g. `"Red"`, `"Orange"`). Only used when
  `user_date` is provided.

- end_date:

  Optional last date of a range of historical alerts.

- base_url:

  Base URL of the TransitMatters API.

## Value

A list of alerts. Historical alerts have `valid_from`, `valid_to`, and
`text`; current alerts have `id`, `type`, `header`, `active_period`,
`stops`, `routes`, and `description`.

## Details

Alert times are `POSIXct` date-times in Eastern time.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_alerts()
tm_alerts("2024-01-15", route = "Red")
tm_alerts("2024-01-15", route = "Red", end_date = "2024-01-21")
} # }
```
