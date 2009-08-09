IN: compiler.cfg.loop-detection.tests
USING: compiler.cfg compiler.cfg.loop-detection
compiler.cfg.predecessors
compiler.cfg.debugger
tools.test kernel namespaces accessors ;

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb

0 { 1 2 } edges
2 0 edge

: test-loop-detection ( -- ) cfg new 0 get >>entry needs-loops drop ;

[ ] [ test-loop-detection ] unit-test

[ 1 ] [ 0 get loop-nesting-at ] unit-test
[ 0 ] [ 1 get loop-nesting-at ] unit-test
[ 1 ] [ 2 get loop-nesting-at ] unit-test
