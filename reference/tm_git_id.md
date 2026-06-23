# Get the deployed git commit ID

Get the deployed git commit ID

## Usage

``` r
tm_git_id(base_url = tm_base_url())
```

## Arguments

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with the git commit SHA of the running server.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_git_id()
} # }
```
