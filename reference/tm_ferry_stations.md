# List all stations on a ferry route

List all stations on a ferry route

## Usage

``` r
tm_ferry_stations(route)
```

## Arguments

- route:

  Ferry route ID. Use
  [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md)
  to see all valid IDs.

## Value

A data frame with columns `stop_name`, `station`, `order`, and
`terminus`.

## Examples

``` r
tm_ferry_stations("Boat-F1")
#>                      stop_name      station order terminus
#> 1           Long Wharf (North)    Boat-Long     6     TRUE
#> 2                  Rowes Wharf   Boat-Rowes     5    FALSE
#> 3 Logan Airport Ferry Terminal   Boat-Logan     4    FALSE
#> 4               Georges Island  Boat-George     3    FALSE
#> 5                         Hull    Boat-Hull     2    FALSE
#> 6                      Hingham Boat-Hingham     1     TRUE
```
