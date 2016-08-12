USING: accessors compiler.cfg.loop-detection
compiler.cfg.loop-detection.private compiler.cfg.utilities
compiler.test kernel namespaces sequences sets tools.test ;
IN: compiler.cfg.loop-detection.tests

{ V{ 0 } { 1 } } [
    V{ } 0 insns>block V{ } 1 insns>block [ connect-bbs ] keep
    f f <natural-loop> [ process-loop-block ] keep
    blocks>> members
    [ [ number>> ] map ] bi@
] unit-test

! process-loop-ends
{ } [
    f f <natural-loop> process-loop-ends
] unit-test


V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb

0 { 1 2 } edges
2 0 edge

: test-loop-detection ( -- )
    0 get block>cfg needs-loops ;

{ } [ test-loop-detection ] unit-test

{ 1 } [ 0 get loop-nesting-at ] unit-test
{ 0 } [ 1 get loop-nesting-at ] unit-test
{ 1 } [ 2 get loop-nesting-at ] unit-test
