USING: kernel math math.constants math.functions math.private
math.libm tools.test ;
IN: temporary

[ t ] [ 4 4 .00000001 ~ ] unit-test
[ t ] [ 4.0000001 4.0000001 .000001 ~ ] unit-test
[ f ] [ -4.0000001 4.0000001 .00001 ~ ] unit-test
[ t ] [ -.0000000000001 0 .0000000001 ~ ] unit-test

! Lets get the argument order correct, eh?
[ 0.0 ] [ 0.0 1.0 fatan2 ] unit-test
[ 0.25 ] [ 2.0 -2.0 fpow ] unit-test

[ 4.0 ] [ 16 sqrt ] unit-test
[ C{ 0 4.0 } ] [ -16 sqrt ] unit-test

[ 4.0 ] [ 2 2 ^ ] unit-test
[ 0.25 ] [ 2 -2 ^ ] unit-test
[ t ] [ 2 0.5 ^ 2 ^ 2 2.00001 between? ] unit-test
[ t ] [ e pi i * ^ real -1.0 = ] unit-test
[ t ] [ e pi i * ^ imaginary -0.00001 0.00001 between? ] unit-test

[ t ] [ 0 0 ^ fp-nan? ] unit-test
[ 1.0/0.0 ] [ 0 -2 ^ ] unit-test
[ t ] [ 0 0.0 ^ fp-nan? ] unit-test
[ 1.0/0.0 ] [ 0 -2.0 ^ ] unit-test
[ 0 ] [ 0 3.0 ^ ] unit-test
[ 0 ] [ 0 3 ^ ] unit-test

[ 1.0 ] [ 0 cosh ] unit-test
[ 0.0 ] [ 1 acosh ] unit-test
            
[ 1.0 ] [ 0 cos ] unit-test
[ 0.0 ] [ 1 acos ] unit-test
            
[ 0.0 ] [ 0 sinh ] unit-test
[ 0.0 ] [ 0 asinh ] unit-test
            
[ 0.0 ] [ 0 sin ] unit-test
[ 0.0 ] [ 0 asin ] unit-test

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

: verify-gcd
    2dup gcd
    >r rot * swap rem r> = ; 

[ t ] [ 123 124 verify-gcd ] unit-test
[ t ] [ 50 120 verify-gcd ] unit-test

[ 3 ] [ 5 7 mod-inv ] unit-test
[ 78572682077 ] [ 234829342 342389423843 mod-inv ] unit-test

[ 2 10 mod-inv ] unit-test-fails
