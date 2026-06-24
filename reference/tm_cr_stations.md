# List all stations on a commuter rail line

List all stations on a commuter rail line

## Usage

``` r
tm_cr_stations(route)
```

## Arguments

- route:

  CR route ID. Use
  [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md)
  to see all valid IDs.

## Value

A data frame with columns `stop_name`, `station` (GTFS place ID),
`order`, and `terminus`.

## Examples

``` r
tm_cr_stations("CR-Fairmount")
#>             stop_name       station order terminus
#> 1           Readville place-DB-0095     1     TRUE
#> 2           Fairmount place-DB-2205     2    FALSE
#> 3    Blue Hill Avenue place-DB-2222     3    FALSE
#> 4       Morton Street place-DB-2230     4    FALSE
#> 5       Talbot Avenue place-DB-2240     5    FALSE
#> 6 Four Corners/Geneva place-DB-2249     6    FALSE
#> 7       Uphams Corner place-DB-2258     7    FALSE
#> 8           Newmarket place-DB-2265     8    FALSE
#> 9       South Station   place-sstat     9     TRUE
```
