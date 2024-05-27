IN: promises.tests
USING: promises math tools.test namespaces kernel ;

LAZY: lazy-test ( a -- b ) 1 + ;

{ 1 1 } [ lazy-test ] must-infer-as
{ 3 } [ 2 lazy-test force ] unit-test

SYMBOL: call-count
SYMBOL: simple-lazy

[ call-count inc 1 ] <promise> simple-lazy set
{ 1 } [ simple-lazy get force ] unit-test
{ 1 } [ simple-lazy get force ] unit-test


SYMBOL: throw-foo-count
SYMBOL: throw-foo
[ throw-foo-count inc "foo" throw ] <promise> throw-foo set

[ throw-foo get force ] [ "foo" = ] must-fail-with
[ throw-foo get force ] [ "foo" = ] must-fail-with

{ 1 } [ throw-foo-count get ] unit-test
