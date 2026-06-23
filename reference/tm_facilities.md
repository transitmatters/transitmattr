# List MBTA facilities

List MBTA facilities

## Usage

``` r
tm_facilities(base_url = tm_base_url())
```

## Arguments

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of facility objects.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_facilities()
} # }
```
