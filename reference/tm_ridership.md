# Get ridership data

Returns ridership counts over a date range, optionally filtered to a
single MBTA line.

## Usage

``` r
tm_ridership(start_date, end_date, line_id = NULL, base_url = tm_base_url())
```

## Arguments

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- line_id:

  Optional MBTA line identifier. Accepts any of `"Red"`, `"red"`,
  `"line-red"`, or `"line-Red"` — all are equivalent.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of ridership records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_ridership("2024-01-01", "2024-01-31")
tm_ridership("2024-01-01", "2024-01-31", line_id = "Red")
} # }
```
