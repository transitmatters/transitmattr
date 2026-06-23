# Get trip metrics by line

Returns per-trip performance metrics aggregated over a date range.

## Usage

``` r
tm_trip_metrics(start_date, end_date, agg, line, base_url = tm_base_url())
```

## Arguments

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- agg:

  Aggregation level, e.g. `"daily"` or `"weekly"`.

- line:

  MBTA line identifier, e.g. `"line-red"`.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of trip metric records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_trip_metrics("2024-01-01", "2024-01-31", agg = "daily", line = "line-red")
} # }
```
