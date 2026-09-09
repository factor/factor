USING: accessors arrays compiler.cfg.register-allocation.greedy.regions
kernel locals math math.bitwise math.order sequences tools.test ;
IN: compiler.cfg.register-allocation.greedy.regions.tests

! A hot loop with a transparent latch remains in a register. The cold entry
! and exit are forced to memory: two cold edge transfers beat repeated hot
! reloads, including when layout places the latch elsewhere.
{ { f t t f } 2 } [
    { { 0 t } { 64 f } { 0 f } { 0 t } }
    { { 0 1 1 } { 1 2 8 } { 2 1 8 } { 2 3 1 } }
    solve-residency [ resident>> ] [ cost>> ] bi
] unit-test

! A cold use adjacent to heavily weighted forced-memory edges stays in
! memory. This is a cost decision; the register is locally available.
{ { f f f } 2 } [
    { { 0 t } { 2 f } { 0 t } }
    { { 0 1 8 } { 1 2 8 } }
    solve-residency [ resident>> ] [ cost>> ] bi
] unit-test

! Hard interference always wins over arbitrarily expensive use costs.
{ { f } 1000000 } [
    { { 1000000 t } } { } solve-residency [ resident>> ] [ cost>> ] bi
] unit-test

! No interference means the whole connected region needs no spill traffic.
{ { t t t } 0 } [
    { { 2 f } { 0 f } { 2 f } }
    { { 0 1 8 } { 1 2 8 } }
    solve-residency [ resident>> ] [ cost>> ] bi
] unit-test

! Independent exhaustive oracle for small networks. This enumerates every
! labeling, without residual paths, and compares the minimum energy.
:: labeling-cost ( mask nodes edges -- cost )
    nodes [| node i | node second mask i bit? and ] map-index [ ] any? [ 1/0. ] [
        nodes [| node i | mask i bit? [ 0 ] [ node first ] if ] map-index sum
        edges [| edge |
            mask edge first bit? mask edge second bit? = [ 0 ] [ edge third ] if
        ] map-sum +
    ] if ;

{ t } [
    32 <iota> [| seed |
        seed 3 mod 1 + f 2array
        seed 5 mod 2 + seed 2 bit? 2array
        seed 7 mod 1 + t 2array 3array
        seed 3 bit? [ { { 0 1 2 } { 1 2 5 } { 2 0 1 } } ]
        [ { { 0 1 8 } { 1 2 1 } } ] if
        [| nodes edges |
            8 <iota> [ nodes edges labeling-cost ] map infimum
            nodes edges solve-residency cost>> =
        ] call
    ] all?
] unit-test
