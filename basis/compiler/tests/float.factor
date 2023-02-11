USING: compiler.units compiler.test kernel kernel.private memory
math math.private tools.test math.floats.private math.order fry
specialized-arrays sequences math.functions layouts literals ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
SPECIALIZED-ARRAY: c:double
IN: compiler.tests.float

{ 3.0 1 2 3 } [ 1.0 2.0 [ float+ 1 2 3 ] compile-call ] unit-test

{ $[ float type-number ] } [ 1.0 [ 2.0 float+ tag ] compile-call ] unit-test

{ 3.0 } [ 1.0 [ 2.0 float+ ] compile-call ] unit-test
{ 3.0 } [ 1.0 [ 2.0 swap float+ ] compile-call ] unit-test
{ 3.0 } [ 1.0 2.0 [ float+ ] compile-call ] unit-test
{ 3.0 } [ 1.0 2.0 [ swap float+ ] compile-call ] unit-test

{ -1.0 } [ 1.0 [ 2.0 float- ] compile-call ] unit-test
{ 1.0 } [ 1.0 [ 2.0 swap float- ] compile-call ] unit-test
{ -1.0 } [ 1.0 2.0 [ float- ] compile-call ] unit-test
{ 1.0 } [ 1.0 2.0 [ swap float- ] compile-call ] unit-test

{ 6.0 } [ 3.0 [ 2.0 float* ] compile-call ] unit-test
{ 6.0 } [ 3.0 [ 2.0 swap float* ] compile-call ] unit-test
{ 6.0 } [ 3.0 2.0 [ float* ] compile-call ] unit-test
{ 6.0 } [ 3.0 2.0 [ swap float* ] compile-call ] unit-test

{ 0.5 } [ 1.0 [ 2.0 float/f ] compile-call ] unit-test
{ 2.0 } [ 1.0 [ 2.0 swap float/f ] compile-call ] unit-test
{ 0.5 } [ 1.0 2.0 [ float/f ] compile-call ] unit-test
{ 2.0 } [ 1.0 2.0 [ swap float/f ] compile-call ] unit-test

{ t } [ 1.0 2.0 [ float< ] compile-call ] unit-test
{ t } [ 1.0 [ 2.0 float< ] compile-call ] unit-test
{ f } [ 1.0 [ 2.0 swap float< ] compile-call ] unit-test
{ f } [ 1.0 1.0 [ float< ] compile-call ] unit-test
{ f } [ 1.0 [ 1.0 float< ] compile-call ] unit-test
{ f } [ 1.0 [ 1.0 swap float< ] compile-call ] unit-test
{ f } [ 3.0 1.0 [ float< ] compile-call ] unit-test
{ f } [ 3.0 [ 1.0 float< ] compile-call ] unit-test
{ t } [ 3.0 [ 1.0 swap float< ] compile-call ] unit-test

{ t } [ 1.0 2.0 [ float<= ] compile-call ] unit-test
{ t } [ 1.0 [ 2.0 float<= ] compile-call ] unit-test
{ f } [ 1.0 [ 2.0 swap float<= ] compile-call ] unit-test
{ t } [ 1.0 1.0 [ float<= ] compile-call ] unit-test
{ t } [ 1.0 [ 1.0 float<= ] compile-call ] unit-test
{ t } [ 1.0 [ 1.0 swap float<= ] compile-call ] unit-test
{ f } [ 3.0 1.0 [ float<= ] compile-call ] unit-test
{ f } [ 3.0 [ 1.0 float<= ] compile-call ] unit-test
{ t } [ 3.0 [ 1.0 swap float<= ] compile-call ] unit-test

{ f } [ 1.0 2.0 [ float> ] compile-call ] unit-test
{ f } [ 1.0 [ 2.0 float> ] compile-call ] unit-test
{ t } [ 1.0 [ 2.0 swap float> ] compile-call ] unit-test
{ f } [ 1.0 1.0 [ float> ] compile-call ] unit-test
{ f } [ 1.0 [ 1.0 float> ] compile-call ] unit-test
{ f } [ 1.0 [ 1.0 swap float> ] compile-call ] unit-test
{ t } [ 3.0 1.0 [ float> ] compile-call ] unit-test
{ t } [ 3.0 [ 1.0 float> ] compile-call ] unit-test
{ f } [ 3.0 [ 1.0 swap float> ] compile-call ] unit-test

{ f } [ 1.0 2.0 [ float>= ] compile-call ] unit-test
{ f } [ 1.0 [ 2.0 float>= ] compile-call ] unit-test
{ t } [ 1.0 [ 2.0 swap float>= ] compile-call ] unit-test
{ t } [ 1.0 1.0 [ float>= ] compile-call ] unit-test
{ t } [ 1.0 [ 1.0 float>= ] compile-call ] unit-test
{ t } [ 1.0 [ 1.0 swap float>= ] compile-call ] unit-test
{ t } [ 3.0 1.0 [ float>= ] compile-call ] unit-test
{ t } [ 3.0 [ 1.0 float>= ] compile-call ] unit-test
{ f } [ 3.0 [ 1.0 swap float>= ] compile-call ] unit-test

{ f } [ 1.0 2.0 [ float= ] compile-call ] unit-test
{ t } [ 1.0 1.0 [ float= ] compile-call ] unit-test
{ f } [ 1.0 [ 2.0 float= ] compile-call ] unit-test
{ t } [ 1.0 [ 1.0 float= ] compile-call ] unit-test
{ f } [ 1.0 [ 2.0 swap float= ] compile-call ] unit-test
{ t } [ 1.0 [ 1.0 swap float= ] compile-call ] unit-test

{ t } [ 0.0 [ dup 0.0 float= swap -0.0 float= or ] compile-call ] unit-test
{ t } [ -0.0 [ dup 0.0 float= swap -0.0 float= or ] compile-call ] unit-test
{ f } [ 3.0 [ dup 0.0 float= swap -0.0 float= or ] compile-call ] unit-test

{ 313.0 } [ 313 [ fixnum>float ] compile-call ] unit-test
{ -313 } [ -313.5 [ float>fixnum ] compile-call ] unit-test
{ 313 } [ 313.5 [ float>fixnum ] compile-call ] unit-test
{ 315 315.0 } [ 313 [ 2 fixnum+fast dup fixnum>float ] compile-call ] unit-test

{ t } [ 0/0. 0/0. [ float-unordered? ] compile-call ] unit-test
{ t } [ 0/0. 1.0 [ float-unordered? ] compile-call ] unit-test
{ t } [ 1.0 0/0. [ float-unordered? ] compile-call ] unit-test
{ f } [ 3.0 1.0 [ float-unordered? ] compile-call ] unit-test
{ f } [ 1.0 3.0 [ float-unordered? ] compile-call ] unit-test

{ 1 } [ 0/0. 0/0. [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
{ 1 } [ 0/0. 1.0 [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
{ 1 } [ 1.0 0/0. [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
{ 2 } [ 3.0 1.0 [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
{ 2 } [ 1.0 3.0 [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test

: two-floats ( a b -- a b ) { float float } declare ; inline

{ -11.3 } [ -11.3 17.5 [ two-floats min ] compile-call ] unit-test
{ -11.3 } [ 17.5 -11.3 [ two-floats min ] compile-call ] unit-test
{ 17.5 } [ -11.3 17.5 [ two-floats max ] compile-call ] unit-test
{ 17.5 } [ 17.5 -11.3 [ two-floats max ] compile-call ] unit-test

! Test loops
{ 30.0 } [
    float-array{ 1 2 3 4 } float-array{ 1 2 3 4 }
    [ { float-array float-array } declare [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

{ 30.0 } [
    float-array{ 1 2 3 4 }
    [ { float-array } declare dup [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

{ 30.0 } [
    float-array{ 1 2 3 4 }
    [ { float-array } declare [ dup * ] [ + ] map-reduce ] compile-call
] unit-test

{ 4.5 } [
    float-array{ 1.0 3.5 }
    [ { float-array } declare 0.0 [ + ] reduce ] compile-call
] unit-test

{ float-array{ 2.0 4.5 } } [
    float-array{ 1.0 3.5 }
    [ { float-array } declare [ 1 + ] map ] compile-call
] unit-test

{ t } [
    [ double-array{ 1.0 2.0 3.0 } 0.0 [ + ] reduce sqrt ] compile-call
    2.44948 0.0001 ~
] unit-test

{ 7.5 3 } [
    [
        double-array{ 1.0 2.0 3.0 }
        1.5 [ + ] reduce dup 0.0 < [ 2 ] [ 3 ] if
    ] compile-call
] unit-test
