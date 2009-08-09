IN: compiler.cfg.dominance.tests
USING: tools.test sequences vectors namespaces kernel accessors assocs sets
math.ranges arrays compiler.cfg compiler.cfg.dominance compiler.cfg.debugger
compiler.cfg.predecessors ;

: test-dominance ( -- )
    cfg new 0 get >>entry
    needs-dominance drop ;

! Example with no back edges
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

[ ] [ test-dominance ] unit-test

[ t ] [ 0 get dom-parent 0 get eq? ] unit-test
[ t ] [ 1 get dom-parent 0 get eq? ] unit-test
[ t ] [ 2 get dom-parent 0 get eq? ] unit-test
[ t ] [ 4 get dom-parent 0 get eq? ] unit-test
[ t ] [ 3 get dom-parent 1 get eq? ] unit-test
[ t ] [ 5 get dom-parent 4 get eq? ] unit-test

[ t ] [ 0 get dom-children 1 get 2 get 4 get 3array set= ] unit-test

[ t ] [ 0 get 3 get dominates? ] unit-test
[ f ] [ 3 get 4 get dominates? ] unit-test
[ f ] [ 1 get 4 get dominates? ] unit-test
[ t ] [ 4 get 5 get dominates? ] unit-test
[ f ] [ 1 get 5 get dominates? ] unit-test

! Example from the paper
V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb

0 { 1 2 } edges
1 3 edge
2 4 edge
3 4 edge
4 3 edge

[ ] [ test-dominance ] unit-test

[ t ] [ 0 4 [a,b] [ get dom-parent 0 get eq? ] all? ] unit-test

! The other example from the paper
V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V{ } 4 test-bb
V{ } 5 test-bb

0 { 1 2 } edges
1 5 edge
2 { 4 3 } edges
5 4 edge
4 { 5 3 } edges
3 4 edge

[ ] [ test-dominance ] unit-test

[ t ] [ 0 5 [a,b] [ get dom-parent 0 get eq? ] all? ] unit-test
