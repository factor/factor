USING: accessors arrays assocs
compiler.cfg.register-allocation.chordal.spilling.residency
kernel locals math math.combinatorics math.order sequences sets
sorting tools.test ;
IN: compiler.cfg.register-allocation.chordal.spilling.residency.tests

! A protected imminent use survives even when it has the most distant
! following use. Dead residents need no store; saved residents reuse home.
{ { 4 3 } } [
    { 1 2 3 4 } { 1 2 5 } H{ { 1 100 } { 2 1 } { 3 40 } } 3
    pressure-victims
] unit-test

{ { 3 } } [
    { 4 3 2 } { 2 } H{ { 1 100 } { 2 1 } { 3 40 } } eviction-stores
] unit-test

[ { 1 } { 1 2 3 } H{ } 2 pressure-victims ]
[ impossible-register-pressure? ] must-fail-with

! Preserve the complete original selection as a differential oracle. The
! zero-pressure shortcut must leave positive-pressure ordering unchanged.
:: original-pressure-victims ( residents demanded distances capacity -- victims )
    demanded members :> protected
    protected length capacity >
    [ protected capacity impossible-register-pressure ] when
    residents protected union length capacity - 0 max :> excess
    residents protected diff
    [ distances eviction-priority ] sort-by <reversed>
    excess head ;

! Exhaust every subset of four values as resident/protected sets, all bank
! capacities, and dead/equal/different next uses. Duplicates in both input
! sequences must not create pressure, and nonnumeric sequence order must
! not replace the SSA-number tie break.
{ t } [ [let
    { 4 1 3 2 } all-subsets :> subsets
    { H{ } H{ { 1 0 } { 2 0 } { 3 0 } { 4 0 } }
      H{ { 1 3 } { 2 1 } { 3 3 } }
      H{ { 1 100002 } { 2 1 } { 4 2 } } } :> distances
    subsets [| resident-set |
        subsets [| demanded-set |
            5 <iota> [| capacity |
                demanded-set length capacity <= [
                    distances [| next-uses |
                        { f t } [| duplicates? |
                            resident-set duplicates? [ dup append ] when :> residents
                            demanded-set duplicates? [ dup append ] when :> demanded
                            residents demanded next-uses capacity pressure-victims
                            residents demanded next-uses capacity original-pressure-victims =
                        ] all?
                    ] all?
                ] [ t ] if
            ] all?
        ] all?
    ] all?
] ] unit-test

! Independent expected answers protect the oracle's priority conventions.
{ { } { } { 4 3 2 1 } { 4 3 } } [
    { } { } H{ } 0 pressure-victims
    { 1 1 } { 1 1 } H{ } 1 pressure-victims
    { 4 1 3 2 } { } H{ } 0 pressure-victims
    { 4 1 3 2 } { } H{ { 1 7 } { 2 7 } { 3 7 } { 4 7 } } 2 pressure-victims
] unit-test

! Even an empty resident set must reject impossible mandatory operands.
[ { } { 2 2 } H{ } 0 pressure-victims ] [
    dup impossible-register-pressure?
    [ [ demanded>> { 2 } = ] [ capacity>> zero? ] bi and ] [ drop f ] if
] must-fail-with

! Common predecessor residency outranks an optional edge reload; otherwise
! minimum next use wins. No branch-specific value is silently assumed live.
{ { 3 2 } } [
    { 1 2 3 } { 3 } H{ { 1 100002 } { 2 4 } { 3 7 } } 2
    select-entry-residents
] unit-test

{ { 2 } { 3 } } [
    { 1 2 } { 1 } { 1 3 } { 1 2 } edge-transfers
] unit-test
