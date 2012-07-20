USING: stack-checker.backend tools.test kernel namespaces
stack-checker.state stack-checker.values sequences assocs ;
IN: stack-checker.backend.tests

[ ] [
    V{ } clone (meta-d) set
    V{ } clone (meta-r) set
    V{ } clone literals set
    H{ } clone known-values set
    0 input-count set
    0 inner-d-index set
] unit-test

[ 0 ] [ 0 ensure-d length ] unit-test

[ 2 ] [ 2 ensure-d length ] unit-test

[ t ] [ meta-d [ known-values get at input-parameter? ] all? ] unit-test

[ 2 ] [ meta-d length ] unit-test

[ 3 ] [ 3 ensure-d length ] unit-test
[ 3 ] [ meta-d length ] unit-test

[ 1 ] [ 1 ensure-d length ] unit-test
[ 3 ] [ meta-d length ] unit-test

[ ] [ 1 consume-d drop ] unit-test
