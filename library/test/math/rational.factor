IN: scratchpad
USE: arithmetic
USE: kernel
USE: stack
USE: test

[ t ] [ 0 fixnum? ] unit-test
[ t ] [ 2345621 fixnum? ] unit-test

[ t ] [ 2345621 dup >bignum >fixnum = ] unit-test

[ t ] [ 0 >fixnum 0 >bignum = ] unit-test
[ f ] [ 0 >fixnum 1 >bignum = ] unit-test
[ f ] [ 1 >bignum 0 >bignum = ] unit-test
[ t ] [ 0 >bignum 0 >fixnum = ] unit-test

[ t ] [ 0 >bignum bignum? ] unit-test
[ f ] [ 0 >fixnum bignum? ] unit-test
[ f ] [ 0 >fixnum bignum? ] unit-test
[ t ] [ 0 >fixnum fixnum? ] unit-test

[ -1 ] [ 1 neg ] unit-test
[ -1 ] [ 1 >bignum neg ] unit-test

[ 9 3 ] [ 93 10 /mod ] unit-test
[ 9 3 ] [ 93 >bignum 10 /mod ] unit-test

[ 5 ] [ 2 >bignum 3 >bignum + ] unit-test

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

[ 3 ] [ 10/3 >integer ] unit-test
[ -3 ] [ -10/3 >integer ] unit-test
