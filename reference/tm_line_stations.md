# List all stations on a rapid transit line

Returns a data frame of every station on the line, useful for
discovering valid station names to pass to
[`tm_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_stop_id.md)
and
[`tm_place_id()`](https://transitmatters.github.io/transitmattr/reference/tm_place_id.md).

## Usage

``` r
tm_line_stations(line)
```

## Arguments

- line:

  Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or `"Mattapan"`
  (case-insensitive; `"line-red"` form also accepted).

## Value

A data frame with columns `stop_name`, `station` (GTFS place ID),
`order`, and `branches`.

## Examples

``` r
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
tm_line_stations("Green")
#>                    stop_name     station order   branches
#> 1              Medford/Tufts place-mdftf     1          E
#> 2                Ball Square place-balsq     2          E
#> 3              Magoun Square place-mgngl     3          E
#> 4              Gilman Square place-gilmn     4          E
#> 5            East Somerville place-esomr     5          E
#> 6               Union Square place-unsqu     6          D
#> 7                   Lechmere  place-lech     7       D, E
#> 8               Science Park place-spmnl     8       D, E
#> 9              North Station place-north     9    C, D, E
#> 10                 Haymarket place-haecl    10    C, D, E
#> 11         Government Center place-gover    11 B, C, D, E
#> 12               Park Street place-pktrm    12 B, C, D, E
#> 13                  Boylston place-boyls    13 B, C, D, E
#> 14                 Arlington place-armnl    14 B, C, D, E
#> 15                    Copley place-coecl    15 B, C, D, E
#> 16                     Hynes place-hymnl    16    B, C, D
#> 17                   Kenmore place-kencl    17    B, C, D
#> 18          Blandford Street place-bland   101          B
#> 19    Boston University East place-buest   102          B
#> 20 Boston University Central place-bucen   103          B
#> 21              Amory Street place-amory   105          B
#> 22            Babcock Street place-babck   107          B
#> 23           Packards Corner place-brico   108          B
#> 24            Harvard Avenue place-harvd   109          B
#> 25             Griggs Street place-grigg   110          B
#> 26            Allston Street place-alsgr   111          B
#> 27             Warren Street place-wrnst   112          B
#> 28         Washington Street place-wascm   113          B
#> 29           Sutherland Road place-sthld   114          B
#> 30             Chiswick Road place-chswk   115          B
#> 31      Chestnut Hill Avenue place-chill   116          B
#> 32              South Street place-sougr   117          B
#> 33            Boston College  place-lake   118          B
#> 34        Saint Marys Street place-smary   201          C
#> 35              Hawes Street place-hwsst   202          C
#> 36               Kent Street place-kntst   203          C
#> 37     Saint Paul Street (C) place-stpul   204          C
#> 38           Coolidge Corner  place-cool   205          C
#> 39             Summit Avenue place-sumav   206          C
#> 40              Brandon Hall place-bndhl   207          C
#> 41          Fairbanks Street place-fbkst   208          C
#> 42         Washington Square place-bcnwa   209          C
#> 43             Tappan Street place-tapst   210          C
#> 44                 Dean Road place-denrd   211          C
#> 45          Englewood Avenue place-engav   212          C
#> 46          Cleveland Circle place-clmnl   213          C
#> 47                    Fenway place-fenwy   301          D
#> 48                  Longwood place-longw   302          D
#> 49         Brookline Village place-bvmnl   303          D
#> 50           Brookline Hills place-brkhl   304          D
#> 51              Beaconsfield place-bcnfd   305          D
#> 52                 Reservoir place-rsmnl   306          D
#> 53             Chestnut Hill place-chhil   307          D
#> 54             Newton Centre place-newto   308          D
#> 55          Newton Highlands place-newtn   309          D
#> 56                     Eliot place-eliot   310          D
#> 57                     Waban place-waban   311          D
#> 58                  Woodland place-woodl   312          D
#> 59                 Riverside place-river   313          D
#> 60                Prudential place-prmnl   401          E
#> 61                  Symphony place-symcl   402          E
#> 62   Northeastern University place-nuniv   403          E
#> 63       Museum of Fine Arts   place-mfa   404          E
#> 64     Longwood Medical Area place-lngmd   405          E
#> 65            Brigham Circle place-brmnl   406          E
#> 66              Fenwood Road place-fenwd   407          E
#> 67              Mission Park place-mispk   408          E
#> 68                  Riverway place-rvrwy   409          E
#> 69          Back of the Hill place-bckhl   410          E
#> 70              Heath Street place-hsmnl   411          E
```
