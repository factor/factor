USING: kernel namespaces tools.test words ;
IN: namespaces.tests

H{ } clone "test-namespace" set

: test-namespace ( -- )
    H{ } clone dup [ namespace = ] bind ;

[ t ] [ test-namespace ] unit-test

10 "some-global" set
[ f ]
[ H{ } clone [ f "some-global" set "some-global" get ] bind ]
unit-test

SYMBOL: test-initialize
test-initialize [ 1 ] initialize
test-initialize [ 2 ] initialize

[ 1 ] [ test-initialize get-global ] unit-test

f test-initialize set-global
test-initialize [ 5 ] initialize

[ 5 ] [ test-initialize get-global ] unit-test
