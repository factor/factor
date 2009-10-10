USING: compiler.units compiler kernel kernel.private memory math
math.private tools.test math.floats.private ;
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

[ 17.5 ] [ -11.3 17.5 [ float-max ] compile-call ] unit-test
[ 17.5 ] [ 17.5 -11.3 [ float-max ] compile-call ] unit-test
[ -11.3 ] [ -11.3 17.5 [ float-min ] compile-call ] unit-test
[ -11.3 ] [ 17.5 -11.3 [ float-min ] compile-call ] unit-test

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
