USING: assocs compiler.tree.debugger kernel namespaces
tools.test ;
IN: namespaces.tests

H{ } clone "test-namespace" set

: test-namespace ( -- ? )
    H{ } clone dup [ namespace = ] with-variables ;

{ t } [ test-namespace ] unit-test

10 "some-global" set
{ f }
[ H{ } clone [ f "some-global" set "some-global" get ] with-variables ]
unit-test

SYMBOL: test-initialize

f test-initialize set-global

test-initialize [ 1 ] initialize
test-initialize [ 2 ] initialize

{ 1 } [ test-initialize get-global ] unit-test

f test-initialize set-global
test-initialize [ 5 ] initialize

{ 5 } [ test-initialize get-global ] unit-test

SYMBOL: toggle-test
{ f } [ toggle-test get ] unit-test
{ t } [ toggle-test [ toggle ] [ get ] bi ] unit-test
{ f } [ toggle-test [ toggle ] [ get ] bi ] unit-test

{ t } [ toggle-test [ on ] [ get ] bi ] unit-test
{ f } [ toggle-test [ off ] [ get ] bi ] unit-test

{ t } [ [ test-initialize get-global ] { at* set-at } inlined? ] unit-test
{ t } [ [ test-initialize set-global ] { at* set-at } inlined? ] unit-test
