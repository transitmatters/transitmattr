# Get direction names for a rapid transit line

Returns the direction labels used by a line, which are the valid string
values for the `direction` argument of
[`tm_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_stop_id.md).

## Usage

``` r
tm_line_directions(line)
```

## Arguments

- line:

  Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or `"Mattapan"`
  (case-insensitive; `"line-red"` form also accepted).

## Value

A named character vector, e.g.
`c("0" = "northbound", "1" = "southbound")`.

## Examples

``` r
tm_line_directions("Red")
#>            0            1 
#> "northbound" "southbound" 
tm_line_directions("Green")
#>           0           1 
#> "eastbound" "westbound" 
```
