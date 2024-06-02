USING: accessors arrays generic.single kernel math
math.functions slots tools.test words eval vocabs.parser ;
IN: slots.tests

TUPLE: r/w-test foo ;

TUPLE: r/o-test { foo read-only } ;

[ r/o-test new 123 >>foo ] [ no-method? ] must-fail-with

TUPLE: decl-test { foo array } ;

[ decl-test new "" >>foo ] [ bad-slot-value? ] must-fail-with

TUPLE: hello length ;

{ 3 } [ "xyz" length>> ] unit-test

[ "xyz" 4 >>length ] [ no-method? ] must-fail-with

! Test protocol slots
SLOT: my-protocol-slot-test

TUPLE: protocol-slot-test-tuple x ;

M: protocol-slot-test-tuple my-protocol-slot-test>> x>> sq ;
M: protocol-slot-test-tuple my-protocol-slot-test<< [ sqrt ] dip x<< ;

{ 9 } [ T{ protocol-slot-test-tuple { x 3 } } my-protocol-slot-test>> ] unit-test

{ 4.0 } [
    T{ protocol-slot-test-tuple { x 3 } } clone
    [ 7 + ] change-my-protocol-slot-test x>>
] unit-test

UNION: comme-ci integer float ;
UNION: comme-ca integer float ;
comme-ca 25.5 "initial-value" set-word-prop

{ 0 t }    [ comme-ci initial-value ] unit-test
{ 25.5 t } [ comme-ca initial-value ] unit-test

[
    "IN: slots.tests TUPLE: foobar { foo myfoobarx } ;"
    eval( -- ) ]
[ error>> error>> no-word-error? ] must-fail-with

[
    "IN: TUPLE: class-bad-initial-value { aslot array initial: 5 } ;"
    eval ( -- )
] [ array? ] must-fail-with
