IN: temporary
USING: kernel namespaces tools.test words ;

H{ } clone "test-namespace" set

: test-namespace ( -- )
    H{ } clone dup [ namespace = ] bind ;

[ t ] [ test-namespace ] unit-test

10 "some-global" set
[ f ]
[ H{ } clone [ f "some-global" set "some-global" get ] bind ]
unit-test
