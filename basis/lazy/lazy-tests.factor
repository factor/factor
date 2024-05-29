USING: accessors continuations kernel lazy math namespaces
tools.test ;
IN: lazy.tests

LAZY: lazy-test ( a -- b ) 1 + ;

{ 1 1 } [ lazy-test ] must-infer-as
{ 3 } [ 2 lazy-test force ] unit-test

SYMBOL: call-count
SYMBOL: simple-lazy

[ call-count inc 1 ] <lazy> simple-lazy set
{ 1 } [ simple-lazy get force ] unit-test
{ 1 } [ simple-lazy get force ] unit-test


SYMBOL: throw-foo-count
SYMBOL: throw-foo
[ throw-foo-count inc "foo" throw ] <lazy> throw-foo set

[ throw-foo get force ] [ "foo" = ] must-fail-with
[ throw-foo get force ] [ "foo" = ] must-fail-with

{ 1 } [ throw-foo-count get ] unit-test

{ 5 } [ 5 <value> force ] unit-test

{ 42 f } [
    [ 42 ] <lazy> [ force ] [ quot>> ] bi
] unit-test

{ f } [
    [ "broken" throw ] <lazy> [ force ] ignore-errors quot>>
] unit-test
