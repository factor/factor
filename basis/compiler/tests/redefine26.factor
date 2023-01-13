USING: accessors classes.tuple classes.maybe compiler.units
kernel math slots tools.test classes.union ;
IN: compiler.tests.redefine26

TUPLE: yoo ;
TUPLE: hoo ;

UNION: foo integer yoo ;

TUPLE: redefine-test-26 { a maybe{ foo } } ;

: store-26 ( -- obj ) redefine-test-26 new 26 >>a ;
: store-26. ( -- obj ) redefine-test-26 new 26. >>a ;
: store-yoo ( -- obj ) redefine-test-26 new T{ yoo } >>a ;
: store-hoo ( -- obj ) redefine-test-26 new T{ hoo } >>a ;

{ f } [ redefine-test-26 new a>> ] unit-test
{ 26 } [ store-26 a>> ] unit-test
{ T{ yoo } } [ store-yoo a>> ] unit-test
[ store-26. a>> ] [ bad-slot-value? ] must-fail-with
[ store-hoo a>> ] [ bad-slot-value? ] must-fail-with

{ } [
    [
        \ foo { integer hoo } define-union-class
    ] with-compilation-unit
] unit-test

{ f } [ redefine-test-26 new a>> ] unit-test
{ 26 } [ store-26 a>> ] unit-test
{ T{ hoo } } [ store-hoo a>> ] unit-test
[ store-26. a>> ] [ bad-slot-value? ] must-fail-with
[ store-yoo a>> ] [ bad-slot-value? ] must-fail-with
