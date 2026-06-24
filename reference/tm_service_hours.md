# Get service hours data

Returns scheduled vs. delivered service hours aggregated over a date
range for a single MBTA line.

## Usage

``` r
tm_service_hours(
  start_date,
  end_date,
  agg,
  line_id = NULL,
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

- line_id:

  MBTA line identifier, e.g. `"line-red"`.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of service hours records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_service_hours("2024-01-01", "2024-01-31", agg = "daily",
                 line_id = "line-red")
} # }
```
