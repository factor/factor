IN: temporary
USING: compiler kernel kernel.private memory math
math.private tools.test math.floats.private ;

[ 5.0 ] [ [ 5.0 ] compile-1 data-gc data-gc data-gc ] unit-test
[ 2.0 3.0 ] [ 3.0 [ 2.0 swap ] compile-1 ] unit-test

[ 1 2 3 4.0 ] [ [ 1 2 3 4.0 ] compile-1 ] unit-test

[ 3.0 1 2 3 ] [ 1.0 2.0 [ float+ 1 2 3 ] compile-1 ] unit-test

[ 5 ] [ 1.0 [ 2.0 float+ tag ] compile-1 ] unit-test

[ 3.0 ] [ 1.0 [ 2.0 float+ ] compile-1 ] unit-test
[ 3.0 ] [ 1.0 [ 2.0 swap float+ ] compile-1 ] unit-test
[ 3.0 ] [ 1.0 2.0 [ float+ ] compile-1 ] unit-test
[ 3.0 ] [ 1.0 2.0 [ swap float+ ] compile-1 ] unit-test

[ -1.0 ] [ 1.0 [ 2.0 float- ] compile-1 ] unit-test
[ 1.0 ] [ 1.0 [ 2.0 swap float- ] compile-1 ] unit-test
[ -1.0 ] [ 1.0 2.0 [ float- ] compile-1 ] unit-test
[ 1.0 ] [ 1.0 2.0 [ swap float- ] compile-1 ] unit-test

[ 6.0 ] [ 3.0 [ 2.0 float* ] compile-1 ] unit-test
[ 6.0 ] [ 3.0 [ 2.0 swap float* ] compile-1 ] unit-test
[ 6.0 ] [ 3.0 2.0 [ float* ] compile-1 ] unit-test
[ 6.0 ] [ 3.0 2.0 [ swap float* ] compile-1 ] unit-test

[ 0.5 ] [ 1.0 [ 2.0 float/f ] compile-1 ] unit-test
[ 2.0 ] [ 1.0 [ 2.0 swap float/f ] compile-1 ] unit-test
[ 0.5 ] [ 1.0 2.0 [ float/f ] compile-1 ] unit-test
[ 2.0 ] [ 1.0 2.0 [ swap float/f ] compile-1 ] unit-test

[ t ] [ 1.0 2.0 [ float< ] compile-1 ] unit-test
[ t ] [ 1.0 [ 2.0 float< ] compile-1 ] unit-test
[ f ] [ 1.0 [ 2.0 swap float< ] compile-1 ] unit-test
[ f ] [ 1.0 1.0 [ float< ] compile-1 ] unit-test
[ f ] [ 1.0 [ 1.0 float< ] compile-1 ] unit-test
[ f ] [ 1.0 [ 1.0 swap float< ] compile-1 ] unit-test
[ f ] [ 3.0 1.0 [ float< ] compile-1 ] unit-test
[ f ] [ 3.0 [ 1.0 float< ] compile-1 ] unit-test
[ t ] [ 3.0 [ 1.0 swap float< ] compile-1 ] unit-test

[ t ] [ 1.0 2.0 [ float<= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 2.0 float<= ] compile-1 ] unit-test
[ f ] [ 1.0 [ 2.0 swap float<= ] compile-1 ] unit-test
[ t ] [ 1.0 1.0 [ float<= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 1.0 float<= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 1.0 swap float<= ] compile-1 ] unit-test
[ f ] [ 3.0 1.0 [ float<= ] compile-1 ] unit-test
[ f ] [ 3.0 [ 1.0 float<= ] compile-1 ] unit-test
[ t ] [ 3.0 [ 1.0 swap float<= ] compile-1 ] unit-test

[ f ] [ 1.0 2.0 [ float> ] compile-1 ] unit-test
[ f ] [ 1.0 [ 2.0 float> ] compile-1 ] unit-test
[ t ] [ 1.0 [ 2.0 swap float> ] compile-1 ] unit-test
[ f ] [ 1.0 1.0 [ float> ] compile-1 ] unit-test
[ f ] [ 1.0 [ 1.0 float> ] compile-1 ] unit-test
[ f ] [ 1.0 [ 1.0 swap float> ] compile-1 ] unit-test
[ t ] [ 3.0 1.0 [ float> ] compile-1 ] unit-test
[ t ] [ 3.0 [ 1.0 float> ] compile-1 ] unit-test
[ f ] [ 3.0 [ 1.0 swap float> ] compile-1 ] unit-test

[ f ] [ 1.0 2.0 [ float>= ] compile-1 ] unit-test
[ f ] [ 1.0 [ 2.0 float>= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 2.0 swap float>= ] compile-1 ] unit-test
[ t ] [ 1.0 1.0 [ float>= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 1.0 float>= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 1.0 swap float>= ] compile-1 ] unit-test
[ t ] [ 3.0 1.0 [ float>= ] compile-1 ] unit-test
[ t ] [ 3.0 [ 1.0 float>= ] compile-1 ] unit-test
[ f ] [ 3.0 [ 1.0 swap float>= ] compile-1 ] unit-test

[ f ] [ 1.0 2.0 [ float= ] compile-1 ] unit-test
[ t ] [ 1.0 1.0 [ float= ] compile-1 ] unit-test
[ f ] [ 1.0 [ 2.0 float= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 1.0 float= ] compile-1 ] unit-test
[ f ] [ 1.0 [ 2.0 swap float= ] compile-1 ] unit-test
[ t ] [ 1.0 [ 1.0 swap float= ] compile-1 ] unit-test

[ t ] [ 0.0 [ dup 0.0 float= swap -0.0 float= or ] compile-1 ] unit-test
[ t ] [ -0.0 [ dup 0.0 float= swap -0.0 float= or ] compile-1 ] unit-test
[ f ] [ 3.0 [ dup 0.0 float= swap -0.0 float= or ] compile-1 ] unit-test

[ 315 315.0 ] [ 313 [ 2 fixnum+fast dup fixnum>float ] compile-1 ] unit-test
