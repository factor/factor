USING: compiler.cfg.register-allocation.chordal.spilling.residency
tools.test ;
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

! Common predecessor residency outranks an optional edge reload; otherwise
! minimum next use wins. No branch-specific value is silently assumed live.
{ { 3 2 } } [
    { 1 2 3 } { 3 } H{ { 1 100002 } { 2 4 } { 3 7 } } 2
    select-entry-residents
] unit-test

{ { 2 } { 3 } } [
    { 1 2 } { 1 } { 1 3 } { 1 2 } edge-transfers
] unit-test
