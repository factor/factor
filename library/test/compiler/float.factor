IN: temporary
USING: compiler kernel memory math math-internals test ;

[ 5.0 ] [ [ 5.0 ] compile-1 full-gc full-gc full-gc ] unit-test
[ 2.0 3.0 ] [ 3.0 [ 2.0 swap ] compile-1 ] unit-test

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
