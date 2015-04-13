USING: compiler.cfg.debugger compiler.cfg compiler.cfg.linearization
compiler.cfg.utilities kernel accessors sequences sets tools.test namespaces ;
IN: compiler.cfg.linearization.tests

V{ } 0 test-bb

V{ } 1 test-bb

V{ } 2 test-bb

0 { 1 1 } edges
1 2 edge

{ { 0 1 2 } } [
    0 get block>cfg linearization-order [ number>> ] map
] unit-test
