# Finding Stops by Name

Every API function that returns per-trip data (headways, dwells, travel
times) needs a **stop ID** — a string that identifies exactly where on
the network you want to look. These IDs are opaque by design: `"70061"`
is Alewife, `"1-1-110"` is Harvard inbound on Route 1,
`"Boat-F1|1|Boat-Hingham"` is Hingham Ferry inbound. Nobody has these
memorised.

The `tm_*_stop_id()` family converts human-readable names into the IDs
the API expects. This vignette is a quick reference for all four transit
modes.

------------------------------------------------------------------------

## Rapid Transit

The five rapid transit lines are **Red**, **Orange**, **Blue**,
**Green**, and **Mattapan**.

### Discover: what stations are on this line?

``` r

library(transitmattr)
tm_line_stations("Red")
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

tm_line_directions("Red")   # northbound / southbound
#>            0            1 
#> "northbound" "southbound"
tm_line_directions("Green") # eastbound  / westbound
#>           0           1 
#> "eastbound" "westbound"
```

### Look up a stop ID

``` r

# Davis, trains heading toward Alewife (northbound)
tm_stop_id("Red", "Davis", "northbound")
#> [1] "70064"

# Alewife is a terminus — same stop ID in both directions
tm_stop_id("Red", "Alewife", "northbound")
#> [1] "70061"
tm_stop_id("Red", "Alewife", "southbound")
#> [1] "70061"
```

You can also use `0`/`1` instead of direction names if you prefer:

``` r

tm_stop_id("Red", "Davis", 0)  # same as "northbound"
#> [1] "70064"
tm_stop_id("Red", "Davis", 1)  # same as "southbound"
#> [1] "70063"
```

### Look up a place ID

Some aggregate endpoints (like
[`tm_aggregate_travel_times()`](https://transitmatters.github.io/transitmattr/reference/tm_aggregate_travel_times.md))
take a **place ID** instead of a stop ID. Place IDs refer to a whole
station, not a platform.

``` r

tm_place_id("Red", "Park Street")
#> [1] "place-pktrm"
tm_place_id("Red", "Davis")
#> [1] "place-davis"
```

### Using these in API calls

``` r

# Headways at Davis, trains heading toward Alewife
tm_headways("2024-01-15",
  stop = tm_stop_id("Red", "Davis", "northbound")
)

# Travel time: Park Street → Davis (aggregate endpoint uses place IDs)
tm_aggregate_travel_times2(
  from_stop  = tm_place_id("Red", "Park Street"),
  to_stop    = tm_place_id("Red", "Davis"),
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
```

------------------------------------------------------------------------

## Bus

There are 121 bus routes in the constants. Directions are always
`"outbound"` and `"inbound"`.

### Discover: what routes are available?

``` r

# Returns all route IDs — sorted, so standard routes come first
head(tm_bus_routes(), 15)
#>  [1] "1"           "10"          "100"         "101"         "104"        
#>  [6] "104/109"     "105"         "106"         "108"         "109"        
#> [11] "11"          "110"         "111"         "112"         "114/116/117"
```

### Discover: what stops are on this route?

``` r

# Route 1 runs between Harvard and Nubian
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

### Look up a stop ID

``` r

# Harvard, boarding a Route 1 toward Nubian (inbound)
tm_bus_stop_id("1", "Harvard", "inbound")
#> [1] "1-1-110"

# Harvard, boarding a Route 1 toward Watertown (outbound)
tm_bus_stop_id("1", "Harvard", "outbound")
#> [1] "1-0-110"
```

Bus stop IDs encode the route and direction — `"1-1-110"` means route 1,
direction 1 (inbound), stop sequence 110.

### Using these in API calls

``` r

# Headways at Harvard on Route 1, inbound, on a specific day
harvard_headways = tm_headways("2024-01-15",
  stop = tm_bus_stop_id("1", "Harvard", "inbound")
)

# Aggregate headways at Nubian over a month
aggregate_headways_1 = tm_aggregate_headways(
  stop       = tm_bus_stop_id("1", "Nubian Station", "inbound"),
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
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

The `terminus` column flags the endpoints of each line.

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

### Look up a stop ID

CR stations can have multiple platform stop IDs for the same station. At
**terminus** stations, one direction may have no stops (trains only
depart, not arrive, in the other direction).

``` r

# Fairmount station, outbound (toward Readville)
tm_cr_stop_id("CR-Fairmount", "Fairmount", "outbound")
#> [1] "CR-Fairmount_0_DB-2205-01" "CR-Fairmount_0_DB-2205-02"

# South Station, inbound — terminus, so no inbound stops
tm_cr_stop_id("CR-Fairmount", "South Station", "inbound")
#> character(0)

# South Station, outbound — all platforms
tm_cr_stop_id("CR-Fairmount", "South Station", "outbound")
#> [1] "CR-Fairmount_0_NEC-2287"    "CR-Fairmount_0_NEC-2287-01"
#> [3] "CR-Fairmount_0_NEC-2287-07" "CR-Fairmount_0_NEC-2287-08"
#> [5] "CR-Fairmount_0_NEC-2287-09" "CR-Fairmount_0_NEC-2287-10"
#> [7] "CR-Fairmount_0_NEC-2287-11" "CR-Fairmount_0_NEC-2287-12"
#> [9] "CR-Fairmount_0_NEC-2287-13"
```

### Look up a place ID

CR stations have proper GTFS place IDs (unlike bus or ferry). Use these
with
[`tm_aggregate_travel_times()`](https://transitmatters.github.io/transitmattr/reference/tm_aggregate_travel_times.md).

``` r

tm_cr_place_id("CR-Fairmount", "South Station")
#> [1] "place-sstat"
tm_cr_place_id("CR-Fairmount", "Fairmount")
#> [1] "place-DB-2205"
```

### Using these in API calls

``` r

# Headways at Fairmount station, outbound
tm_headways("2024-01-15",
  stop = tm_cr_stop_id("CR-Fairmount", "Fairmount", "outbound")
)

# Aggregate travel time, Fairmount → South Station
tm_aggregate_travel_times(
  from_stop  = tm_cr_place_id("CR-Fairmount", "Fairmount"),
  to_stop    = tm_cr_place_id("CR-Fairmount", "South Station"),
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
```

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

# F1: Long Wharf ↔ Hingham
tm_ferry_stations("Boat-F1")
#>                      stop_name      station order terminus
#> 1           Long Wharf (North)    Boat-Long     6     TRUE
#> 2                  Rowes Wharf   Boat-Rowes     5    FALSE
#> 3 Logan Airport Ferry Terminal   Boat-Logan     4    FALSE
#> 4               Georges Island  Boat-George     3    FALSE
#> 5                         Hull    Boat-Hull     2    FALSE
#> 6                      Hingham Boat-Hingham     1     TRUE
```

### Look up a stop ID

``` r

# Hingham, boarding a ferry to Long Wharf (inbound)
tm_ferry_stop_id("Boat-F1", "Hingham", "inbound")
#> [1] "Boat-F1|1|Boat-Hingham"

# Long Wharf (North), boarding a ferry to Hingham (outbound)
tm_ferry_stop_id("Boat-F1", "Long Wharf (North)", "outbound")
#> [1] "Boat-F1|0|Boat-Long"
```

### Using these in API calls

``` r

# Headways at Hingham, inbound
ferry_headways = tm_headways("2024-06-01",
  stop = tm_ferry_stop_id("Boat-F1", "Hingham", "inbound")
)
```

------------------------------------------------------------------------

## Quick reference

| Mode | Routes fn | Stations fn | Stop ID fn | Place ID fn |
|----|----|----|----|----|
| Rapid transit | — | `tm_line_stations(line)` | `tm_stop_id(line, stop, dir)` | `tm_place_id(line, stop)` |
| Bus | [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md) | `tm_bus_stations(route)` | `tm_bus_stop_id(route, stop, dir)` | — |
| Commuter Rail | [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md) | `tm_cr_stations(route)` | `tm_cr_stop_id(route, stop, dir)` | `tm_cr_place_id(route, stop)` |
| Ferry | [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md) | `tm_ferry_stations(route)` | `tm_ferry_stop_id(route, stop, dir)` | — |

All stop-name arguments are **case-insensitive**. Line and route
arguments are also case-insensitive (`"red"` and `"Red"` both work).
