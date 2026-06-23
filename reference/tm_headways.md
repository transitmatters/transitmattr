# Get headway data for a date

Get headway data for a date

## Usage

``` r
tm_headways(user_date, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object or a `"YYYY-MM-DD"` string.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with a `headways` element containing per-route headway data.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_headways("2024-01-15")
tm_headways(as.Date("2024-01-15"))
} # }
```
