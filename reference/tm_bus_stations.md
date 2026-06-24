# List all stations on a bus route

List all stations on a bus route

## Usage

``` r
tm_bus_stations(route)
```

## Arguments

- route:

  Bus route ID. Use
  [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md)
  to see all valid IDs.

## Value

A data frame with columns `stop_name`, `station`, and `order`.

## Examples

``` r
tm_bus_stations("1")
#>                    stop_name station order
#> 1                    Harvard   hhgat     1
#> 2      Mass Ave & Putnam Ave   maput     2
#> 3 Central Square (Cambridge)   cntsq     3
#> 4             MIT @ Mass Ave     mit     4
#> 5              Hynes Station   hynes     5
#> 6     Mass Ave (Orange Line)   masta     6
#> 7      Mass Ave @ Washington   wasma     7
#> 8   Melnea Cass @ Washington   melwa     8
#> 9             Nubian Station    nubn     9
```
