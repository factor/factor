USING: accessors compiler.cfg.debugger compiler.cfg compiler.cfg.linearization
compiler.cfg.linearization.private compiler.cfg.utilities dlists kernel make
namespaces sequences tools.test  ;
IN: compiler.cfg.linearization.tests

! linearization-order
V{ } 0 test-bb

V{ } 1 test-bb

V{ } 2 test-bb

0 { 1 1 } edges
1 2 edge

{ { 0 1 2 } } [
    0 get block>cfg linearization-order [ number>> ] map
] unit-test

! process-block
{ { } V{ 10 } } [
    HS{ } clone visited set
    V{ } 10 insns>block [ process-block ] V{ } make
    [ number>> ] map
] unit-test
