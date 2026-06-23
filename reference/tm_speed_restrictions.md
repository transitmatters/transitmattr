# Get slow zone / speed restriction data

Returns current or historical speed restrictions for an MBTA line on a
given date.

## Usage

``` r
tm_speed_restrictions(line_id, date, base_url = tm_base_url())
```

## Arguments

- line_id:

  MBTA line identifier, e.g. `"line-red"`.

- date:

  The date to query. A `Date` object or `"YYYY-MM-DD"` string.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of speed restriction records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_speed_restrictions("line-red", "2024-01-15")
} # }
```
