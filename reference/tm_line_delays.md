# Get delay data by line

Returns alert-based delay summaries for an MBTA line over a date range.

## Usage

``` r
tm_line_delays(start_date, end_date, line, base_url = tm_base_url())
```

## Arguments

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- line:

  MBTA line identifier, e.g. `"line-red"`.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of line delay records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_line_delays("2024-01-01", "2024-01-31", line = "line-red")
} # }
```
