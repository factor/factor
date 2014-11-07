USING: compiler.cfg compiler.cfg.loop-detection compiler.cfg.debugger
compiler.cfg.predecessors compiler.cfg.utilities tools.test kernel namespaces
accessors ;
IN: compiler.cfg.loop-detection.tests

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb

0 { 1 2 } edges
2 0 edge

: test-loop-detection ( -- )
    0 get block>cfg needs-loops drop ;

[ ] [ test-loop-detection ] unit-test

[ 1 ] [ 0 get loop-nesting-at ] unit-test
[ 0 ] [ 1 get loop-nesting-at ] unit-test
[ 1 ] [ 2 get loop-nesting-at ] unit-test
