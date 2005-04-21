IN: temporary
USING: kernel math test unparser ;

[ "-8" ] [ -8 unparse ] unit-test

[ t ] [ 0 fixnum? ] unit-test
[ t ] [ 31415 number? ] unit-test
[ t ] [ 31415 >bignum number? ] unit-test
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

[ 100 ] [ 100 100 gcd nip ] unit-test
[ 100 ] [ 1000 100 gcd nip ] unit-test
[ 100 ] [ 100 1000 gcd nip ] unit-test
[ 4 ] [ 132 64 gcd nip ] unit-test
[ 4 ] [ -132 64 gcd nip ] unit-test
[ 4 ] [ -132 -64 gcd nip ] unit-test
[ 4 ] [ 132 -64 gcd nip ] unit-test
[ 4 ] [ -132 -64 gcd nip ] unit-test

[ 100 ] [ 100 >bignum 100 >bignum gcd nip ] unit-test
[ 100 ] [ 1000 >bignum 100 >bignum gcd nip ] unit-test
[ 100 ] [ 100 >bignum 1000 >bignum gcd nip ] unit-test
[ 4 ] [ 132 >bignum 64 >bignum gcd nip ] unit-test
[ 4 ] [ -132 >bignum 64 >bignum gcd nip ] unit-test
[ 4 ] [ -132 >bignum -64 >bignum gcd nip ] unit-test
[ 4 ] [ 132 >bignum -64 >bignum gcd nip ] unit-test
[ 4 ] [ -132 >bignum -64 >bignum gcd nip ] unit-test

[ 6 ] [
    1326264299060955293181542400000006
    1591517158873146351817850880000000
    gcd nip
] unit-test

: verify-gcd ( x y )
    2dup gcd ( a d )
    >r rot * swap rem r> = ; 

[ t ] [ 123 124 verify-gcd ] unit-test
[ t ] [ 50 120 verify-gcd ] unit-test
[ 3 ] [ 5 7 mod-inv ] unit-test
[ 78572682077 ] [ 234829342 342389423843 mod-inv ] unit-test

[ -1 ] [ -1 >bignum >fixnum ] unit-test

[ "8589934592" ]
[ 134217728 dup + dup + dup + dup + dup + dup + unparse ]
unit-test

[ 268435456 ] [ -268435456 >fixnum -1 / ] unit-test
[ 268435456 ] [ -268435456 >fixnum -1 /i ] unit-test
[ 268435456 0 ] [ -268435456 >fixnum -1 /mod ] unit-test
[ 1/268435456 ] [ -1 -268435456 >fixnum / ] unit-test
[ 0 ] [ -1 -268435456 >fixnum /i ] unit-test
[ 0 -1 ] [ -1 -268435456 >fixnum /mod ] unit-test
[ 14355 ] [ 1591517158873146351817850880000000 32769 mod ] unit-test

[ 0 0 ^ ] unit-test-fails
[ 1 ] [ 10 0 ^ ] unit-test
[ 1/8 ] [ 1/2 3 ^ ] unit-test
[ 1/8 ] [ 2 -3 ^ ] unit-test
[ t ] [ 1 100 shift 2 100 ^ = ] unit-test
