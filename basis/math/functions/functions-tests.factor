USING: kernel math math.constants math.functions math.order
math.private math.libm tools.test ;
IN: math.functions.tests

[ t ] [ 4 4 .00000001 ~ ] unit-test
[ t ] [ 4.0000001 4.0000001 .000001 ~ ] unit-test
[ f ] [ -4.0000001 4.0000001 .00001 ~ ] unit-test
[ t ] [ -.0000000000001 0 .0000000001 ~ ] unit-test

! Lets get the argument order correct, eh?
[ 0.0 ] [ 0.0 1.0 fatan2 ] unit-test
[ 0.25 ] [ 2.0 -2.0 fpow ] unit-test

[ 4.0 ] [ 16 sqrt ] unit-test
[ 2.0 ] [ 4.0 0.5 ^ ] unit-test
[ C{ 0.0 4.0 } ] [ -16 sqrt ] unit-test

[ 4 ] [ 2 2 ^ ] unit-test
[ 1/4 ] [ 2 -2 ^ ] unit-test
[ t ] [ 2 0.5 ^ 2 ^ 2 2.00001 between? ] unit-test
[ t ] [ e pi i* ^ real-part -1.0 = ] unit-test
[ t ] [ e pi i* ^ imaginary-part -0.00001 0.00001 between? ] unit-test

[ t ] [ 0 0 ^ fp-nan? ] unit-test
[ 1/0. ] [ 0 -2 ^ ] unit-test
[ t ] [ 0 0.0 ^ fp-nan? ] unit-test
[ 1/0. ] [ 0 -2.0 ^ ] unit-test
[ 0 ] [ 0 3.0 ^ ] unit-test
[ 0 ] [ 0 3 ^ ] unit-test

[ 0.0 ] [ 1 log ] unit-test

[ 1.0 ] [ 0 cosh ] unit-test
[ 0.0 ] [ 1 acosh ] unit-test

[ 1.0 ] [ 0 cos ] unit-test
[ 0.0 ] [ 1 acos ] unit-test

[ 0.0 ] [ 0 sinh ] unit-test
[ 0.0 ] [ 0 asinh ] unit-test

[ 0.0 ] [ 0 sin ] unit-test
[ 0.0 ] [ 0 asin ] unit-test

[ t ] [ 10 atan real? ] unit-test
[ f ] [ 10 atanh real? ] unit-test

[ t ] [ 10 asin sin 10 1.e-10 ~ ] unit-test
[ t ] [ -1 sqrt neg dup acos cos 1.e-10 ~ ] unit-test
[ t ] [ -100 atan tan -100 1.e-10 ~ ] unit-test
[ t ] [ 10 asinh sinh 10 1.e-10 ~ ] unit-test
[ t ] [ 10 atanh tanh 10 1.e-10 ~ ] unit-test
[ t ] [ 0.5 atanh tanh 0.5 1.e-10 ~ ] unit-test

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

[ 11 ] [
    13262642990609552931815424
    159151715887314635181785
    gcd nip
] unit-test

[ 3 ] [
    13262642990609552931
    1591517158873146351
    gcd nip
] unit-test

[ 26525285981219 ] [
    132626429906095
    159151715887314
    gcd nip
] unit-test


: verify-gcd ( a b -- ? )
    2dup gcd
    [ rot * swap rem ] dip = ;

[ t ] [ 123 124 verify-gcd ] unit-test
[ t ] [ 50 120 verify-gcd ] unit-test

[ t ] [ 0 42 divisor? ] unit-test
[ t ] [ 42 7 divisor? ] unit-test
[ t ] [ 42 -7 divisor? ] unit-test
[ t ] [ 42 42 divisor? ] unit-test
[ f ] [ 42 16 divisor? ] unit-test

[ 3 ] [ 5 7 mod-inv ] unit-test
[ 78572682077 ] [ 234829342 342389423843 mod-inv ] unit-test

[ 2 10 mod-inv ] must-fail

[ t ] [ 0 0 ^ fp-nan? ] unit-test
[ 1 ] [ 10 0 ^ ] unit-test
[ 1/8 ] [ 1/2 3 ^ ] unit-test
[ 1/8 ] [ 2 -3 ^ ] unit-test
[ t ] [ 1 100 shift 2 100 ^ = ] unit-test

[ 1 ] [ 7/8 ceiling ] unit-test
[ 2 ] [ 3/2 ceiling ] unit-test
[ 0 ] [ -7/8 ceiling ] unit-test
[ -1 ] [ -3/2 ceiling ] unit-test

[ 4.0 ] [ 4.5 truncate ] unit-test
[ 4.0 ] [ 4.5 floor ] unit-test
[ 5.0 ] [ 4.5 ceiling ] unit-test

[ -4.0 ] [ -4.5 truncate ] unit-test
[ -5.0 ] [ -4.5 floor ] unit-test
[ -4.0 ] [ -4.5 ceiling ] unit-test

[ -4.0 ] [ -4.0 truncate ] unit-test
[ -4.0 ] [ -4.0 floor ] unit-test
[ -4.0 ] [ -4.0 ceiling ] unit-test

[ -5.0 ] [ -4.5 round ] unit-test
[ -4.0 ] [ -4.4 round ] unit-test
[ 5.0 ] [ 4.5 round ] unit-test
[ 4.0 ] [ 4.4 round ] unit-test

[ 6 59967 ] [ 3837888 factor-2s ] unit-test
[ 6 -59967 ] [ -3837888 factor-2s ] unit-test

[ 1 ] [
    183009416410801897
    1067811677921310779
    2135623355842621559
    ^mod
] unit-test

[ 1 ] [
    183009416410801897
    1067811677921310779
    2135623355842621559
    [ >bignum ] tri@ ^mod
] unit-test

[ 1.0  ] [ 1.0 2.5 0.0 lerp ] unit-test
[ 2.5  ] [ 1.0 2.5 1.0 lerp ] unit-test
[ 1.75 ] [ 1.0 2.5 0.5 lerp ] unit-test

