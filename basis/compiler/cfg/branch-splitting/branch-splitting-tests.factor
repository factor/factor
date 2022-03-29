USING: accessors assocs compiler.cfg.branch-splitting
compiler.cfg.instructions compiler.cfg.predecessors compiler.cfg.rpo
compiler.cfg.utilities compiler.test kernel namespaces tools.test ;
IN: compiler.cfg.branch-splitting.tests

: get-predecessors ( cfg -- assoc )
    H{ } clone [ '[ [ predecessors>> ] keep _ set-at ] each-basic-block ] keep ;

: check-predecessors ( cfg -- )
    [ get-predecessors ]
    [ needs-predecessors ]
    [ get-predecessors ] tri assert= ;

: check-branch-splitting ( cfg -- )
    [ needs-predecessors ] [ split-branches ] [ check-predecessors ] tri ;

: test-branch-splitting ( -- )
    0 get block>cfg check-branch-splitting ;

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{ T{ ##branch } } 4 test-bb

test-diamond

{ } [ test-branch-splitting ] unit-test

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{ T{ ##branch } } 4 test-bb

V{ T{ ##branch } } 5 test-bb

0 { 1 2 } edges

1 { 3 4 } edges

2 { 3 4 } edges

{ } [ test-branch-splitting ] unit-test

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{ T{ ##branch } } 4 test-bb

0 { 1 2 } edges

1 { 3 4 } edges

2 4 edge

{ } [ test-branch-splitting ] unit-test

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

0 { 1 2 } edges

1 2 edge

{ } [ test-branch-splitting ] unit-test
