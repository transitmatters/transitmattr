# Get scheduled service data

Returns scheduled service counts aggregated over a date range.

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

  End of the date range.

- agg:

  Aggregation level: `"daily"` or `"weekly"`.

- route_id:

  Optional MBTA route ID (e.g. `"Red"`, `"Green-B"`). When `NULL`,
  returns data for all routes.

- base_url:

  Base URL of the TransitMatters API.

## Value

A list of scheduled service records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily", route_id = "Red")
} # }
```
