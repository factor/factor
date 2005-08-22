IN: temporary
USE: kernel
USE: math
USE: test

[ 1 2 ] [ 1/2 >fraction ] unit-test

[ 1/2 ] [ 1 >bignum 2 >bignum / ] unit-test
[ t ] [ 10 3 / ratio? ] unit-test
[ f ] [ 10 2 / ratio? ] unit-test
[ 10 ] [ 10 numerator ] unit-test
[ 1 ] [ 10 denominator ] unit-test
[ 12 ] [ -12 -13 / numerator ] unit-test
[ 13 ] [ -12 -13 / denominator ] unit-test
[ 1 ] [ -1 -1 / numerator ] unit-test
[ 1 ] [ -1 -1 / denominator ] unit-test

[ -1 ] [ 2 -2 / ] unit-test
[ -1 ] [ -2 2 / ] unit-test

[ t ] [ 1 3 / 1 3 / = ] unit-test

[ -10 ] [ -100 10 /i ] unit-test
[ 10 ] [ -100 -10 /i ] unit-test
[ -10 ] [ 100 -10 /i ] unit-test
[ -10 ] [ -100 >bignum 10 >bignum /i ] unit-test
[ 10  ] [ -100 >bignum -10 >bignum /i ] unit-test
[ -10 ] [ 100 >bignum -10 >bignum /i ] unit-test

[ 3/2 ] [ 1 1/2 + ] unit-test
[ 3/2 ] [ 1 >bignum 1/2 + ] unit-test
[ -1/2 ] [ 1/2 1 - ] unit-test
[ -1/2 ] [ 1/2 1 >bignum - ] unit-test
[ 41/20 ] [ 5/4 4/5 + ] unit-test

[ 1 ] [ 1/2 2 * ] unit-test
[ 1/3 ] [ 1/2 2/3 * ] unit-test

[ 1 ] [ 1/2 1/2 / ] unit-test
[ 27/4 ] [ 3/2 2/9 / ] unit-test

[ t ] [ 5768 476343 < ] unit-test
[ t ] [ 5768 476343 <= ] unit-test
[ f ] [ 5768 476343 > ] unit-test
[ f ] [ 5768 476343 >= ] unit-test
[ t ] [ 3434 >bignum 3434 >= ] unit-test
[ t ] [ 3434 3434 >bignum <= ] unit-test

[ t ] [ 1 1/3 > ] unit-test
[ t ] [ 2/3 3/4 <= ] unit-test
[ f ] [ -2/3 1/3 > ] unit-test

[ t ] [ 1000000000/999999 1000 > ] unit-test
[ f ] [ 100000 100000000000/999999 > ] unit-test
[ t ]
[ 1000000000000/999999999999 1000000000001/999999999998 < ]
unit-test

[ -3 ] [ -3 10 mod ] unit-test
[ 7 ] [ -3 10 rem ] unit-test
[ 7 ] [ -13 10 rem ] unit-test
[ 0 ] [ 37 37 rem ] unit-test

[ -1 ] [ -12.55 sgn ] unit-test
[ 1 ] [ 100000000000000000000000000000000 sgn ] unit-test
[ 0 ] [ 0.0 sgn ] unit-test

[ 5 ] [ 5 floor ] unit-test
[ -5 ] [ -5 floor ] unit-test
[ 6 ] [ 6 truncate ] unit-test
[ 3 ] [ 10/3 floor ] unit-test
[ -4 ] [ -10/3 floor ] unit-test
[ 4 ] [ 10/3 ceiling ] unit-test
[ -3 ] [ -10/3 ceiling ] unit-test
[ 3 ] [ 10/3 truncate ] unit-test
[ -3 ] [ -10/3 truncate ] unit-test
