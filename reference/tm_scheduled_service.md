# Get scheduled service data

Returns scheduled service counts aggregated over a date range.
Optionally filtered to a single route.

## Usage

``` r
tm_scheduled_service(
  start_date,
  end_date,
  agg,
  route_id = NULL,
  base_url = tm_base_url()
)
```

## Arguments

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- agg:

  Aggregation level, e.g. `"daily"` or `"weekly"`.

- route_id:

  Optional MBTA route ID to filter results.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of scheduled service records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily")
tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily",
                     route_id = "Red")
} # }
```
