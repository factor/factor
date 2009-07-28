USING: accessors arrays compiler.cfg compiler.cfg.debugger
compiler.cfg.dominance compiler.cfg.predecessors
compiler.cfg.ssa.construction.tdmsc kernel namespaces sequences
tools.test vectors sets ;
IN: compiler.cfg.ssa.construction.tdmsc.tests

: test-tdmsc ( -- )
    cfg new 0 get >>entry
    compute-predecessors
    dup compute-dominance
    compute-merge-sets ;

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop
1 get 3 get 1vector >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [ test-tdmsc ] unit-test

[ V{ 4 } ] [ 1 get 1array merge-set [ number>> ] map ] unit-test
[ V{ 4 } ] [ 2 get 1array merge-set [ number>> ] map ] unit-test
[ V{ } ] [ 0 get 1array merge-set ] unit-test
[ V{ } ] [ 4 get 1array merge-set ] unit-test

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb

0 get 1 get 5 get V{ } 2sequence >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 6 get 1vector >>successors drop
5 get 6 get 1vector >>successors drop

[ ] [ test-tdmsc ] unit-test

[ t ] [
    2 get 3 get 2array merge-set
    4 get 6 get 2array set=
] unit-test

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb
V{ } 7 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 1vector >>successors drop
2 get 3 get 6 get V{ } 2sequence >>successors drop
3 get 4 get 1vector >>successors drop
6 get 7 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop
5 get 2 get 1vector >>successors drop

[ ] [ test-tdmsc ] unit-test

[ V{ 2 } ] [ { 2 3 4 5 } [ get ] map merge-set [ number>> ] map ] unit-test
[ V{ } ] [ { 0 1 6 7 } [ get ] map merge-set ] unit-test