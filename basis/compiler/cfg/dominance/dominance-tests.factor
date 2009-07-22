IN: compiler.cfg.dominance.tests
USING: tools.test sequences vectors namespaces kernel accessors assocs sets
math.ranges arrays compiler.cfg compiler.cfg.dominance compiler.cfg.debugger
compiler.cfg.predecessors ;

: test-dominance ( -- )
    cfg new 0 get >>entry
    compute-predecessors
    compute-dominance
    drop ;

! Example with no back edges
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

[ ] [ test-dominance ] unit-test

[ t ] [ 0 get dom-parent 0 get eq? ] unit-test
[ t ] [ 1 get dom-parent 0 get eq? ] unit-test
[ t ] [ 2 get dom-parent 0 get eq? ] unit-test
[ t ] [ 4 get dom-parent 0 get eq? ] unit-test
[ t ] [ 3 get dom-parent 1 get eq? ] unit-test
[ t ] [ 5 get dom-parent 4 get eq? ] unit-test

[ t ] [ 0 get dom-children 1 get 2 get 4 get 3array set= ] unit-test

[ { 4 } ] [ 1 get dom-frontier [ number>> ] map ] unit-test
[ { 4 } ] [ 2 get dom-frontier [ number>> ] map ] unit-test
[ { } ] [ 0 get dom-frontier ] unit-test
[ { } ] [ 4 get dom-frontier ] unit-test

! Example from the paper
V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop
1 get 3 get 1vector >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 3 get 1vector >>successors drop

[ ] [ test-dominance ] unit-test

[ t ] [ 0 4 [a,b] [ get dom-parent 0 get eq? ] all? ] unit-test

! The other example from the paper
V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop
1 get 5 get 1vector >>successors drop
2 get 4 get 3 get V{ } 2sequence >>successors drop
5 get 4 get 1vector >>successors drop
4 get 5 get 3 get V{ } 2sequence >>successors drop
3 get 4 get 1vector >>successors drop

[ ] [ test-dominance ] unit-test

[ t ] [ 0 5 [a,b] [ get dom-parent 0 get eq? ] all? ] unit-test
