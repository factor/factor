IN: scratchpad
USE: arithmetic
USE: kernel
USE: stack
USE: test

[ t ] [ 0.0 float? ] unit-test
[ t ] [ 3.1415 number? ] unit-test
[ f ] [ 12 float? ] unit-test

[ t ] [ 1 1.0 = ] unit-test
[ t ] [ 1 >bignum 1.0 = ] unit-test
[ t ] [ 1.0 1 = ] unit-test
[ t ] [ 1.0 1 >bignum = ] unit-test

[ f ] [ 1 1.3 = ] unit-test
[ f ] [ 1 >bignum 1.3 = ] unit-test
[ f ] [ 1.3 1 = ] unit-test
[ f ] [ 1.3 1 >bignum = ] unit-test

[ t ] [ 134.3 >fixnum 134 eq? ] unit-test

[ 2.1 ] [ -2.1 neg ] unit-test

[ 1 ] [ 0.5 1/2 + ] unit-test
[ 1 ] [ 1/2 0.5 + ] unit-test

[ 3 ] [ 3.1415 >fixnum ] unit-test
[ 3 ] [ 3.1415 >bignum ] unit-test
