USING: accessors arrays compiler.cfg.linear-scan.ranges
compiler.cfg.register-allocation.occupancy kernel locals math sequences
sorting tools.test vectors ;
IN: compiler.cfg.register-allocation.occupancy.tests

:: reference-conflicts ( ranges assigned -- owners )
    assigned [ second ranges intersect-ranges ] filter [ first ] map >array ;

:: check-queries ( occupancy assigned -- ? )
    42 <iota> [| lo |
        42 <iota> [ lo >= ] filter [| hi |
            lo hi 2array 1array :> ranges
            ranges occupancy occupancy-conflicts
            ranges assigned reference-conflicts =
        ] all?
    ] all? ;

! All inclusive boundaries, atomic ranges, holes, empty queries, duplicate
! hits on one owner, and assignment order differing from position order.
{ t { } { 1 2 } } [ [let
    <register-occupancy> :> occupancy
    V{ { 1 { { 20 24 } { 30 34 } } }
       { 2 { { 0 0 } { 4 10 } } }
       { 3 { { 12 18 } { 36 40 } } } } :> assigned
    assigned [ first2 occupancy occupy-ranges ] each
    occupancy assigned check-queries
    { } occupancy occupancy-conflicts >array
    { { 5 6 } { 21 22 } { 31 32 } } occupancy occupancy-conflicts
] ] unit-test

! Eviction removes every range, and reassignment acquires a fresh serial.
{ t { 2 3 1 } } [ [let
    <register-occupancy> :> occupancy
    V{ { 1 { { 20 24 } { 30 34 } } }
       { 2 { { 0 0 } { 4 10 } } }
       { 3 { { 12 18 } { 36 40 } } } } clone :> assigned
    assigned [ first2 occupancy occupy-ranges ] each
    1 occupancy release-ranges
    assigned unclip suffix :> reordered
    reordered last first2 occupancy occupy-ranges
    occupancy reordered check-queries
    { { 0 40 } } occupancy occupancy-conflicts
] ] unit-test

! Splitting an evicted owner replaces its old coverage, including the hole
! created by spilling. No cached range survives into either child.
{ t { 2 3 } } [ [let
    <register-occupancy> :> occupancy
    1 { { 0 40 } } occupancy occupy-ranges
    1 occupancy release-ranges
    V{ { 2 { { 0 10 } } } { 3 { { 30 40 } } } } :> assigned
    assigned [ first2 occupancy occupy-ranges ] each
    occupancy assigned check-queries
    { { 0 40 } } occupancy occupancy-conflicts
] ] unit-test
