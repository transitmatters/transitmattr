# Finding Stops by Name

In `transitmattr`, you never have to look up or memorise stop IDs.
Instead, you build a **query object** for a transit mode and line/route,
then call `$stop("Station Name")` — the library resolves the correct
stop ID automatically.

This vignette shows how to discover valid station names and build
queries for all four transit modes.

------------------------------------------------------------------------

## Rapid Transit

The five rapid transit lines are **Red**, **Orange**, **Blue**,
**Green**, and **Mattapan**.

### Discover: what stations are on this line?

``` r

tm_rt_query("Red")$stations()
#>                stop_name     station order branches
#> 1                Alewife place-alfcl     1     A, B
#> 2                  Davis place-davis     2     A, B
#> 3                 Porter place-portr     3     A, B
#> 4                Harvard place-harsq     4     A, B
#> 5                Central place-cntsq     5     A, B
#> 6            Kendall/MIT place-knncl     6     A, B
#> 7            Charles/MGH place-chmnl     7     A, B
#> 8            Park Street place-pktrm     8     A, B
#> 9      Downtown Crossing place-dwnxg     9     A, B
#> 10         South Station place-sstat    10     A, B
#> 11              Broadway place-brdwy    11     A, B
#> 12                Andrew place-andrw    12     A, B
#> 13   JFK/UMass (Ashmont)   place-jfk   101        A
#> 14            Savin Hill place-shmnl   102        A
#> 15         Fields Corner place-fldcr   103        A
#> 16               Shawmut place-smmnl   104        A
#> 17               Ashmont place-asmnl   105        A
#> 18 JFK/UMass (Braintree)   place-jfk   201        B
#> 19          North Quincy place-nqncy   202        B
#> 20             Wollaston place-wlsta   203        B
#> 21         Quincy Center place-qnctr   204        B
#> 22          Quincy Adams place-qamnl   205        B
#> 23             Braintree place-brntn   206        B
```

### Discover: which directions does this line use?

Rapid transit lines use geographic direction names rather than
inbound/outbound.

``` r

tm_rt_query("Red")$directions()   # northbound / southbound
#>            0            1 
#> "northbound" "southbound"
tm_rt_query("Green")$directions() # eastbound  / westbound
#>           0           1 
#> "eastbound" "westbound"
```

### Build a query and fetch data

``` r

# Headways at Davis, all trains (direction resolved from stop ID)
tm_rt_query("Red")$stop("Davis")$headways("2024-01-15")

# For travel times, specify direction (determines which platform stop ID to use)
tm_rt_query("Red")$from_stop("Park Street")$to_stop("Davis")$direction("northbound")$travel_times("2024-01-15")

# Aggregate headways for January 2024 (direction filters to one platform)
tm_rt_query("Red")$stop("Davis")$direction("southbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
```

You can chain builder calls before the terminal call. The query object
accumulates context and validates each input as you set it — typos in
station names produce an error immediately, not at request time.

------------------------------------------------------------------------

## Bus

There are 121 bus routes. Directions are always `"outbound"` and
`"inbound"`.

### Discover: what routes are available?

``` r

head(tm_bus_routes(), 15)
#>  [1] "1"           "10"          "100"         "101"         "104"        
#>  [6] "104/109"     "105"         "106"         "108"         "109"        
#> [11] "11"          "110"         "111"         "112"         "114/116/117"
```

### Discover: what stops are on this route?

``` r

tm_bus_query("1")$stations()
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

### Build a query and fetch data

``` r

# Headways at Harvard on Route 1, inbound, on a specific day
tm_bus_query("1")$stop("Harvard")$headways("2024-01-15")

# Aggregate headways at Harvard over a month
tm_bus_query("1")$stop("Harvard")$direction("inbound")$date_range("2024-01-01", "2024-01-31")$aggregate_headways()
```

------------------------------------------------------------------------

## Commuter Rail

Commuter Rail routes are identified by their GTFS route ID. All 13 lines
are available.

### Discover: what routes are available?

``` r

tm_cr_routes()
#>  [1] "CR-Fairmount"     "CR-Fitchburg"     "CR-Franklin"      "CR-Greenbush"    
#>  [5] "CR-Haverhill"     "CR-Kingston"      "CR-Lowell"        "CR-Middleborough"
#>  [9] "CR-Needham"       "CR-NewBedford"    "CR-Newburyport"   "CR-Providence"   
#> [13] "CR-Worcester"
```

### Discover: what stops are on this line?

The `terminus` column flags the endpoints of each line. Terminus
stations have stop IDs for only one direction — calling `$stop()` on a
terminus station will issue a **warning** to alert you that data may be
incomplete in one direction.

``` r

tm_cr_query("CR-Fairmount")$stations()
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

### Build a query and fetch data

``` r

# Headways at Fairmount, inbound trains (toward South Station)
tm_cr_query("CR-Fairmount")$stop("Fairmount")$headways("2026-06-18")

# Travel time, Fairmount → Blue Hill Avenue, inbound
tm_cr_query("CR-Fairmount")$from_stop("Fairmount")$to_stop("Blue Hill Avenue")$direction("inbound")$travel_times("2026-06-18")
```

> **Terminus warning:** If you call `$stop("South Station")` on a CR
> query, you will see a warning — South Station is a terminus and has
> stop IDs in only one direction. The query still works; the warning is
> informational.

------------------------------------------------------------------------

## Ferry

Six ferry routes are available. Like bus and CR, directions are
`"outbound"` and `"inbound"`.

### Discover: what routes are available?

``` r

tm_ferry_routes()
#> [1] "Boat-EastBoston" "Boat-F1"         "Boat-F4"         "Boat-F6"        
#> [5] "Boat-F7"         "Boat-Lynn"
```

### Discover: what stops are on this route?

``` r

tm_ferry_query("Boat-F1")$stations()
#>                      stop_name      station order terminus
#> 1           Long Wharf (North)    Boat-Long     6     TRUE
#> 2                  Rowes Wharf   Boat-Rowes     5    FALSE
#> 3 Logan Airport Ferry Terminal   Boat-Logan     4    FALSE
#> 4               Georges Island  Boat-George     3    FALSE
#> 5                         Hull    Boat-Hull     2    FALSE
#> 6                      Hingham Boat-Hingham     1     TRUE
```

### Build a query and fetch data

``` r

# Headways at Hingham, inbound (toward Long Wharf)
tm_ferry_query("Boat-F1")$stop("Hingham")$headways("2024-06-01")
```

------------------------------------------------------------------------

## Quick reference

| Mode | Routes fn | Query constructor | Stations method |
|----|----|----|----|
| Rapid transit | — | `tm_rt_query(line)` | `$stations()` |
| Bus | [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md) | `tm_bus_query(route)` | `$stations()` |
| Commuter Rail | [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md) | `tm_cr_query(route)` | `$stations()` |
| Ferry | [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md) | `tm_ferry_query(route)` | `$stations()` |

All station name arguments are **case-insensitive**. Line and route
arguments accept multiple forms (`"red"`, `"Red"`, and `"line-Red"` are
all equivalent).
