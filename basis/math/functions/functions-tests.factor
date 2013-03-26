USING: kernel literals math math.constants math.functions math.libm
math.order math.ranges math.private sequences tools.test ;

IN: math.functions.tests

[ t ] [ 4 4 .00000001 ~ ] unit-test
[ t ] [ 4.0000001 4.0000001 .000001 ~ ] unit-test
[ f ] [ -4.0000001 4.0000001 .00001 ~ ] unit-test
[ t ] [ -.0000000000001 0 .0000000001 ~ ] unit-test
[ t ] [ 100 101 -.9 ~ ] unit-test
[ f ] [ 100 120 -.09 ~ ] unit-test
[ t ] [ 0 0 -.9 ~ ] unit-test
[ f ] [ 0 10 -.9 ~ ] unit-test

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

[ 1/0. ] [ 2.0 1024 ^ ] unit-test
[ 0x1.0p-1024 ] [ 2.0 -1024 ^ ] unit-test

[ t ] [ 0 0 ^ fp-nan? ] unit-test
[ 0.0 ] [ 0.0 1.0 ^ ] unit-test
[ 1/0. ] [ 0 -2 ^ ] unit-test
[ t ] [ 0 0.0 ^ fp-nan? ] unit-test
[ t ] [ 0.0 0.0 ^ fp-nan? ] unit-test
[ 1/0. ] [ 0 -2.0 ^ ] unit-test
[ 0 ] [ 0 3.0 ^ ] unit-test
[ 0 ] [ 0 3 ^ ] unit-test

: factorial ( n -- n! ) [ 1 ] [ [1,b] 1 [ * ] reduce ] if-zero ;

[ 0.0 0 ] [ 0 frexp ] unit-test
[ 0.5 1 ] [ 1 frexp ] unit-test
[ -0.5 1 ] [ -1 frexp ] unit-test
[ 0.5 2 ] [ 2 frexp ] unit-test
[ -0.5 2 ] [ -2 frexp ] unit-test
[ 0.75 2 ] [ 3 frexp ] unit-test
[ -0.75 2 ] [ -3 frexp ] unit-test
[ 0.75 0 ] [ 0.75 frexp ] unit-test
[ -0.75 0 ] [ -0.75 frexp ] unit-test
[ 1/0. ] [ 1/0. frexp drop ] unit-test
[ -1/0. ] [ -1/0. frexp drop ] unit-test
[ t ] [ 0/0. frexp drop fp-nan? ] unit-test
[  0.75 10,002 t ] [  3 10,000 2^ * [ frexp ] [ bignum? ] bi ] unit-test
[ -0.75 10,002 t ] [ -3 10,000 2^ * [ frexp ] [ bignum? ] bi ] unit-test

[ 0.0 ] [ 1 log ] unit-test
[ 0.0 ] [ 1.0 log ] unit-test
[ 1.0 ] [ e log ] unit-test

CONSTANT: log-factorial-1000 0x1.71820d04e2eb6p12
CONSTANT: log10-factorial-1000 0x1.40f3593ed6f8ep11

[ $ log-factorial-1000 t ] [ 1000 factorial [ log ] [ bignum? ] bi ] unit-test
[ C{ $ log-factorial-1000 $ pi } t ] [ 1000 factorial neg [ log ] [ bignum? ] bi ] unit-test

[ 0.0 ] [ 1.0 log10 ] unit-test
[ 1.0 ] [ 10.0 log10 ] unit-test
[ 2.0 ] [ 100.0 log10 ] unit-test
[ 3.0 ] [ 1000.0 log10 ] unit-test
[ 4.0 ] [ 10000.0 log10 ] unit-test
[ $ log10-factorial-1000 t ] [ 1000 factorial [ log10 ] [ bignum? ] bi ] unit-test

[ t ] [ 1 e^ e 1.e-10 ~ ] unit-test
[ f ] [ 1 e^ 0/0. 1.e-10 ~ ] unit-test
[ f ] [ 0/0. 1 e^ 1.e-10 ~ ] unit-test
[ t ] [ 1.0 e^ e 1.e-10 ~ ] unit-test
[ t ] [ -1 e^ e * 1.0 1.e-10 ~ ] unit-test
[ f ] [ 1/0. 1/0. 1.e-10 ~ ] unit-test
[ f ] [ 1/0. -1/0. 1.e-10 ~ ] unit-test
[ f ] [ 1/0. 0/0. 1.e-10 ~ ] unit-test
[ f ] [ 0/0. -1/0. 1.e-10 ~ ] unit-test

[ 1.0 ] [ 0 cosh ] unit-test
[ 1.0 ] [ 0.0 cosh ] unit-test
[ 0.0 ] [ 1 acosh ] unit-test
[ 0.0 ] [ 1.0 acosh ] unit-test

[ 1.0 ] [ 0 cos ] unit-test
[ 1.0 ] [ 0.0 cos ] unit-test
[ 0.0 ] [ 1 acos ] unit-test
[ 0.0 ] [ 1.0 acos ] unit-test

[ 0.0 ] [ 0 sinh ] unit-test
[ 0.0 ] [ 0.0 sinh ] unit-test
[ 0.0 ] [ 0 asinh ] unit-test
[ 0.0 ] [ 0.0 asinh ] unit-test

[ 0.0 ] [ 0 sin ] unit-test
[ 0.0 ] [ 0.0 sin ] unit-test
[ 0.0 ] [ 0 asin ] unit-test
[ 0.0 ] [ 0.0 asin ] unit-test

[ 0.0 ] [ 0 tan ] unit-test
[ t ] [ pi 2 / tan 1.e10 > ] unit-test

[ t ] [ 10 atan real? ] unit-test
[ t ] [ 10.0 atan real? ] unit-test
[ f ] [ 10 atanh real? ] unit-test
[ f ] [ 10.0 atanh real? ] unit-test

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

[ t ] [ 15 37 137 ^mod 15 37 ^ 137 mod = ] unit-test

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

[ -5 ] [ -9/2 round ] unit-test
[ -4 ] [ -22/5 round ] unit-test
[ 5 ] [ 9/2 round ] unit-test
[ 4 ] [ 22/5 round ] unit-test

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

[ C{ 1 2 } ] [ C{ 1 2 } 1 ^ ] unit-test

{ { t t t } } [
    3 3 roots {
        1.442249570307408
        C{ -0.7211247851537038 1.249024766483407 }
        C{ -0.7211247851537049 -1.249024766483406 }
    } [ .01 ~ ] 2map
] unit-test

{ t } [ 3 15 roots [ 15 ^ 3 .01 ~ ] all? ] unit-test

{ .5 } [ 0 sigmoid ] unit-test

{ 1 } [ 12 signum ] unit-test
{ -1 } [ -5.0 signum ] unit-test
{ 0 } [ 0 signum ] unit-test
{ t } [ C{ 3.0 -1.5 } signum C{ 0.8944271909999157 -0.4472135954999579 } 1e-10 ~ ] unit-test

{ 1.0 } [ 1 2 copysign ] unit-test
{ -1.0 } [ 1 -2 copysign ] unit-test
{ 1.0 } [ -1 0 copysign ] unit-test
{ -0.0 } [ 0 -1.0 copysign ] unit-test
{ -1.0 } [ -1 -0.0 copysign ] unit-test
{ 1.5 } [ -1.5 2 copysign ] unit-test
{ -1.5 } [ -1.5 -2 copysign ] unit-test

{ 0.0 } [ 0 2 round-to ] unit-test
{ 1.0 } [ 1 2 round-to ] unit-test
{ 1.23 } [ 1.2349 2 round-to ] unit-test
{ 1.24 } [ 1.2350 2 round-to ] unit-test
{ 1.24 } [ 1.2351 2 round-to ] unit-test
{ -1.23 } [ -1.2349 2 round-to ] unit-test
{ -1.24 } [ -1.2350 2 round-to ] unit-test
{ -1.24 } [ -1.2351 2 round-to ] unit-test
{
    {
        0.0 0.0 10000.0 12000.0 12300.0 12350.0 12346.0 12345.7
        12345.68 12345.679 12345.6789 12345.6789 12345.678901
        12345.6789012 12345.67890123 12345.678901235
    }
} [ 12345.67890123456 -6 9 [a,b] [ round-to ] with map ] unit-test
