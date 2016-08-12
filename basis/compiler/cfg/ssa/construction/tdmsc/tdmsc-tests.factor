USING: accessors arrays compiler.cfg
compiler.cfg.ssa.construction.tdmsc compiler.cfg.utilities
compiler.test kernel namespaces sequences tools.test ;
QUALIFIED: sets
IN: compiler.cfg.ssa.construction.tdmsc.tests

: test-tdmsc ( -- )
    0 get block>cfg dup cfg set
    compute-merge-sets ;

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb

0 { 1 2 } edges
1 3 edge
2 4 edge
3 4 edge
4 5 edge

{ } [ test-tdmsc ] unit-test

{ { 4 } } [ 1 get 1array merge-set [ number>> ] map ] unit-test
{ { 4 } } [ 2 get 1array merge-set [ number>> ] map ] unit-test
{ { } } [ 0 get 1array merge-set ] unit-test
{ { } } [ 4 get 1array merge-set ] unit-test

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb

0 { 1 5 } edges
1 { 2 3 } edges
2 4 edge
3 4 edge
4 6 edge
5 6 edge

{ } [ test-tdmsc ] unit-test

{ t } [
    2 get 3 get 2array merge-set
    4 get 6 get 2array sets:set=
] unit-test

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb
V{ } 7 test-bb

0 1 edge
1 2 edge
2 { 3 6 } edges
3 4 edge
6 7 edge
4 5 edge
5 2 edge

{ } [ test-tdmsc ] unit-test

{ { 2 } } [ { 2 3 4 5 } [ get ] map merge-set [ number>> ] map ] unit-test
{ { } } [ { 0 1 6 7 } [ get ] map merge-set ] unit-test
