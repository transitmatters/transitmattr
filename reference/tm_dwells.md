# Get dwell time data for a date

Get dwell time data for a date

## Usage

``` r
tm_dwells(user_date, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object or a `"YYYY-MM-DD"` string.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with a `dwells` element containing per-route dwell data.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_dwells("2024-01-15")
} # }
```
