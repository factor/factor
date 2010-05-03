USING: compiler.units compiler.test kernel kernel.private memory
math math.private tools.test math.floats.private math.order fry
specialized-arrays sequences ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: compiler.tests.float

[ 5.0 ] [ [ 5.0 ] compile-call gc gc gc ] unit-test
[ 2.0 3.0 ] [ 3.0 [ 2.0 swap ] compile-call ] unit-test

[ 1 2 3 4.0 ] [ [ 1 2 3 4.0 ] compile-call ] unit-test

[ 3.0 1 2 3 ] [ 1.0 2.0 [ float+ 1 2 3 ] compile-call ] unit-test

[ 3 ] [ 1.0 [ 2.0 float+ tag ] compile-call ] unit-test

[ 3.0 ] [ 1.0 [ 2.0 float+ ] compile-call ] unit-test
[ 3.0 ] [ 1.0 [ 2.0 swap float+ ] compile-call ] unit-test
[ 3.0 ] [ 1.0 2.0 [ float+ ] compile-call ] unit-test
[ 3.0 ] [ 1.0 2.0 [ swap float+ ] compile-call ] unit-test

[ -1.0 ] [ 1.0 [ 2.0 float- ] compile-call ] unit-test
[ 1.0 ] [ 1.0 [ 2.0 swap float- ] compile-call ] unit-test
[ -1.0 ] [ 1.0 2.0 [ float- ] compile-call ] unit-test
[ 1.0 ] [ 1.0 2.0 [ swap float- ] compile-call ] unit-test

[ 6.0 ] [ 3.0 [ 2.0 float* ] compile-call ] unit-test
[ 6.0 ] [ 3.0 [ 2.0 swap float* ] compile-call ] unit-test
[ 6.0 ] [ 3.0 2.0 [ float* ] compile-call ] unit-test
[ 6.0 ] [ 3.0 2.0 [ swap float* ] compile-call ] unit-test

[ 0.5 ] [ 1.0 [ 2.0 float/f ] compile-call ] unit-test
[ 2.0 ] [ 1.0 [ 2.0 swap float/f ] compile-call ] unit-test
[ 0.5 ] [ 1.0 2.0 [ float/f ] compile-call ] unit-test
[ 2.0 ] [ 1.0 2.0 [ swap float/f ] compile-call ] unit-test

[ t ] [ 1.0 2.0 [ float< ] compile-call ] unit-test
[ t ] [ 1.0 [ 2.0 float< ] compile-call ] unit-test
[ f ] [ 1.0 [ 2.0 swap float< ] compile-call ] unit-test
[ f ] [ 1.0 1.0 [ float< ] compile-call ] unit-test
[ f ] [ 1.0 [ 1.0 float< ] compile-call ] unit-test
[ f ] [ 1.0 [ 1.0 swap float< ] compile-call ] unit-test
[ f ] [ 3.0 1.0 [ float< ] compile-call ] unit-test
[ f ] [ 3.0 [ 1.0 float< ] compile-call ] unit-test
[ t ] [ 3.0 [ 1.0 swap float< ] compile-call ] unit-test

[ t ] [ 1.0 2.0 [ float<= ] compile-call ] unit-test
[ t ] [ 1.0 [ 2.0 float<= ] compile-call ] unit-test
[ f ] [ 1.0 [ 2.0 swap float<= ] compile-call ] unit-test
[ t ] [ 1.0 1.0 [ float<= ] compile-call ] unit-test
[ t ] [ 1.0 [ 1.0 float<= ] compile-call ] unit-test
[ t ] [ 1.0 [ 1.0 swap float<= ] compile-call ] unit-test
[ f ] [ 3.0 1.0 [ float<= ] compile-call ] unit-test
[ f ] [ 3.0 [ 1.0 float<= ] compile-call ] unit-test
[ t ] [ 3.0 [ 1.0 swap float<= ] compile-call ] unit-test

[ f ] [ 1.0 2.0 [ float> ] compile-call ] unit-test
[ f ] [ 1.0 [ 2.0 float> ] compile-call ] unit-test
[ t ] [ 1.0 [ 2.0 swap float> ] compile-call ] unit-test
[ f ] [ 1.0 1.0 [ float> ] compile-call ] unit-test
[ f ] [ 1.0 [ 1.0 float> ] compile-call ] unit-test
[ f ] [ 1.0 [ 1.0 swap float> ] compile-call ] unit-test
[ t ] [ 3.0 1.0 [ float> ] compile-call ] unit-test
[ t ] [ 3.0 [ 1.0 float> ] compile-call ] unit-test
[ f ] [ 3.0 [ 1.0 swap float> ] compile-call ] unit-test

[ f ] [ 1.0 2.0 [ float>= ] compile-call ] unit-test
[ f ] [ 1.0 [ 2.0 float>= ] compile-call ] unit-test
[ t ] [ 1.0 [ 2.0 swap float>= ] compile-call ] unit-test
[ t ] [ 1.0 1.0 [ float>= ] compile-call ] unit-test
[ t ] [ 1.0 [ 1.0 float>= ] compile-call ] unit-test
[ t ] [ 1.0 [ 1.0 swap float>= ] compile-call ] unit-test
[ t ] [ 3.0 1.0 [ float>= ] compile-call ] unit-test
[ t ] [ 3.0 [ 1.0 float>= ] compile-call ] unit-test
[ f ] [ 3.0 [ 1.0 swap float>= ] compile-call ] unit-test

[ f ] [ 1.0 2.0 [ float= ] compile-call ] unit-test
[ t ] [ 1.0 1.0 [ float= ] compile-call ] unit-test
[ f ] [ 1.0 [ 2.0 float= ] compile-call ] unit-test
[ t ] [ 1.0 [ 1.0 float= ] compile-call ] unit-test
[ f ] [ 1.0 [ 2.0 swap float= ] compile-call ] unit-test
[ t ] [ 1.0 [ 1.0 swap float= ] compile-call ] unit-test

[ t ] [ 0.0 [ dup 0.0 float= swap -0.0 float= or ] compile-call ] unit-test
[ t ] [ -0.0 [ dup 0.0 float= swap -0.0 float= or ] compile-call ] unit-test
[ f ] [ 3.0 [ dup 0.0 float= swap -0.0 float= or ] compile-call ] unit-test

[ 315 315.0 ] [ 313 [ 2 fixnum+fast dup fixnum>float ] compile-call ] unit-test

[ t ] [ 0/0. 0/0. [ float-unordered? ] compile-call ] unit-test
[ t ] [ 0/0. 1.0 [ float-unordered? ] compile-call ] unit-test
[ t ] [ 1.0 0/0. [ float-unordered? ] compile-call ] unit-test
[ f ] [ 3.0 1.0 [ float-unordered? ] compile-call ] unit-test
[ f ] [ 1.0 3.0 [ float-unordered? ] compile-call ] unit-test

[ 1 ] [ 0/0. 0/0. [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
[ 1 ] [ 0/0. 1.0 [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
[ 1 ] [ 1.0 0/0. [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
[ 2 ] [ 3.0 1.0 [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test
[ 2 ] [ 1.0 3.0 [ float-unordered? [ 1 ] [ 2 ] if ] compile-call ] unit-test

! Ensure that float-min and min, and float-max and max, have
! consistent behavior with respect to NaNs

: two-floats ( a b -- a b ) { float float } declare ; inline

[ -11.3 ] [ -11.3 17.5 [ two-floats min ] compile-call ] unit-test
[ -11.3 ] [ 17.5 -11.3 [ two-floats min ] compile-call ] unit-test
[ 17.5 ] [ -11.3 17.5 [ two-floats max ] compile-call ] unit-test
[ 17.5 ] [ 17.5 -11.3 [ two-floats max ] compile-call ] unit-test

: check-compiled-binary-op ( a b word -- )
    [ '[ [ [ two-floats _ execute ] compile-call ] call( a b -- c ) ] ]
    [ '[ _ execute ] ]
    bi 2bi fp-bitwise= ; inline

[ t ] [ 0/0. 3.0 \ min check-compiled-binary-op ] unit-test
[ t ] [ 3.0 0/0. \ min check-compiled-binary-op ] unit-test
[ t ] [ 0/0. 3.0 \ max check-compiled-binary-op ] unit-test
[ t ] [ 3.0 0/0. \ max check-compiled-binary-op ] unit-test

! Test vector ops
[ 30.0 ] [
    float-array{ 1 2 3 4 } float-array{ 1 2 3 4 }
    [ { float-array float-array } declare [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

[ 30.0 ] [
    float-array{ 1 2 3 4 }
    [ { float-array } declare dup [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

[ 30.0 ] [
    float-array{ 1 2 3 4 }
    [ { float-array } declare [ dup * ] [ + ] map-reduce ] compile-call
] unit-test
