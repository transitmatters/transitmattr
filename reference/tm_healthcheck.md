# Check API health

Check API health

## Usage

``` r
tm_healthcheck(base_url = tm_base_url())
```

## Arguments

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with fields `status` (string) and optionally `failed_checks`.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_healthcheck()
} # }
```
