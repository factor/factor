USING: accessors assocs compiler.cfg.instructions
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.live-intervals
compiler.cfg.register-allocation.ssa compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities cpu.architecture kernel namespaces sequences tools.test ;
IN: compiler.cfg.register-allocation.ssa.tests

! Filtering precedes interval finalization: a memory token need not have a
! defining register instruction and must never reach check-start.
{ { 1 } } [
    { 1 2 } [ <live-interval> ] map
    H{ { 2 T{ spill-slot { n 16 } } } } ssa-register-intervals
    [ vreg>> ] map
] unit-test

{ T{ spill-slot { n 16 } } } [ [
    H{ { 2 2 } } leader-map set
    H{ } clone pending-interval-assoc set
    H{ { 2 T{ spill-slot { n 16 } } } } seed-ssa-fixed-locations
    2 phi-vreg>location
] with-scope ] unit-test

[ H{ { 2 99 } } seed-ssa-fixed-locations ]
[ invalid-ssa-fixed-location? ] must-fail-with
