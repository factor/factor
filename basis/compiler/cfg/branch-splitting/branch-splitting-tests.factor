USING: accessors assocs compiler.cfg
compiler.cfg.branch-splitting compiler.cfg.debugger
compiler.cfg.predecessors compiler.cfg.rpo compiler.cfg.instructions fry kernel
tools.test namespaces sequences vectors ;
IN: compiler.cfg.branch-splitting.tests

: get-predecessors ( cfg -- assoc )
    H{ } clone [ '[ [ predecessors>> ] keep _ set-at ] each-basic-block ] keep ;

: check-predecessors ( cfg -- )
    [ get-predecessors ]
    [ compute-predecessors drop ]
    [ get-predecessors ] tri assert= ;

: check-branch-splitting ( cfg -- )
    compute-predecessors
    split-branches
    check-predecessors ;

: test-branch-splitting ( -- )
    cfg new 0 get >>entry check-branch-splitting ;

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{ T{ ##branch } } 4 test-bb

test-diamond

[ ] [ test-branch-splitting ] unit-test

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{ T{ ##branch } } 4 test-bb

V{ T{ ##branch } } 5 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop

1 get 3 get 4 get V{ } 2sequence >>successors drop

2 get 3 get 4 get V{ } 2sequence >>successors drop

[ ] [ test-branch-splitting ] unit-test

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{ T{ ##branch } } 4 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop

1 get 3 get 4 get V{ } 2sequence >>successors drop

2 get 4 get 1vector >>successors drop

[ ] [ test-branch-splitting ] unit-test

V{ T{ ##branch } } 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{ T{ ##branch } } 2 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop

1 get 2 get 1vector >>successors drop

[ ] [ test-branch-splitting ] unit-test