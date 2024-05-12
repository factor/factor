USING: accessors assocs compiler.cfg.linearization
compiler.cfg.linearization.private compiler.cfg.utilities
compiler.test kernel make namespaces sequences tools.test ;
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

: two-successors-cfg ( -- cfg )
    V{ } 10 insns>block
    [ V{ } 20 insns>block connect-bbs ] keep
    [ V{ } 30 insns>block connect-bbs ] keep
    block>cfg ;

! (linearization-order)
{ { 10 20 30 } } [
    two-successors-cfg (linearization-order) [ number>> ] map
] unit-test

{ { 0 1 2 3 4 5 } } [
    6 <iota> [ V{ } clone over insns>block ] map>alist dup
    {
        { 0 1 } { 0 2 } { 0 5 }
        { 2 3 }
        { 3 4 }
        { 4 2 }
    } make-edges
    0 of block>cfg (linearization-order)
    [ number>> ] map
] unit-test

! process-block
{ { } V{ 10 } } [
    HS{ } clone visited set
    V{ } 10 insns>block [ process-block ] V{ } make
    [ number>> ] map
] unit-test

! number-blocks
{ { 0 1 2 } } [
    two-successors-cfg linearization-order dup number-blocks [ number>> ] map
] unit-test
