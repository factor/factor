USING: kernel literals math math.constants math.functions math.libm
math.order ranges math.private sequences tools.test math.floats.env ;

IN: math.functions.tests

{ t } [ 4 4 .00000001 ~ ] unit-test
{ t } [ 4.0000001 4.0000001 .000001 ~ ] unit-test
{ f } [ -4.0000001 4.0000001 .00001 ~ ] unit-test
{ t } [ -.0000000000001 0 .0000000001 ~ ] unit-test
{ t } [ 100 101 -.9 ~ ] unit-test
{ f } [ 100 120 -.09 ~ ] unit-test
{ t } [ 0 0 -.9 ~ ] unit-test
{ f } [ 0 10 -.9 ~ ] unit-test

! Lets get the argument order correct, eh?
{ 0.0 } [ 0.0 1.0 fatan2 ] unit-test
{ 0.25 } [ 2.0 -2.0 fpow ] unit-test

{ 4.0 } [ 16 sqrt ] unit-test
{ 2.0 } [ 4.0 0.5 ^ ] unit-test
{ C{ 0.0 4.0 } } [ -16 sqrt ] unit-test

{ 4 } [ 2 2 ^ ] unit-test
{ 1/4 } [ 2 -2 ^ ] unit-test
{ t } [ 2 0.5 ^ 2 ^ 2 2.00001 between? ] unit-test
{ t } [ e pi i* ^ real-part -1.0 = ] unit-test
{ t } [ e pi i* ^ imaginary-part -0.00001 0.00001 between? ] unit-test

{ 1/0. } [ 2.0 1024 ^ ] unit-test
{ 0x1.0p-1024 } [ 2.0 -1024 ^ ] unit-test

{ t } [ 0 0 ^ fp-nan? ] unit-test
{ 0.0 } [ 0.0 1.0 ^ ] unit-test
{ 1/0. } [ 0 -2 ^ ] unit-test
{ t } [ 0 0.0 ^ fp-nan? ] unit-test
{ t } [ 0.0 0.0 ^ fp-nan? ] unit-test
{ 1/0. } [ 0 -2.0 ^ ] unit-test
{ 0 } [ 0 3.0 ^ ] unit-test
{ 0 } [ 0 3 ^ ] unit-test

: factorial ( n -- n! ) [ 1 ] [ [1..b] 1 [ * ] reduce ] if-zero ;

{ 0.0 0 } [ 0 frexp ] unit-test
{ 0.5 1 } [ 1 frexp ] unit-test
{ -0.5 1 } [ -1 frexp ] unit-test
{ 0.5 2 } [ 2 frexp ] unit-test
{ -0.5 2 } [ -2 frexp ] unit-test
{ 0.75 2 } [ 3 frexp ] unit-test
{ -0.75 2 } [ -3 frexp ] unit-test
{ 0.75 0 } [ 0.75 frexp ] unit-test
{ -0.75 0 } [ -0.75 frexp ] unit-test
{ 1/0. } [ 1/0. frexp drop ] unit-test
{ -1/0. } [ -1/0. frexp drop ] unit-test
{ t } [ 0/0. frexp drop fp-nan? ] unit-test
{  0.75 10,002 t } [  3 10,000 2^ * [ frexp ] [ bignum? ] bi ] unit-test
{ -0.75 10,002 t } [ -3 10,000 2^ * [ frexp ] [ bignum? ] bi ] unit-test

{ 0.0 } [ 0.0 1 ldexp ] unit-test
{ -0.0 } [ -0.0 1 ldexp ] unit-test
{ 1/0. } [ 1/0. 1 ldexp ] unit-test
{ -1/0. } [ -1/0. 1 ldexp ] unit-test
{ t } [ NAN: 90210 dup 1 ldexp [ fp-nan-payload ] same? ] unit-test
{ 49152.0 } [ 12.0 12 ldexp ] unit-test
{ 0x1.8p-9 } [ 12.0 -12 ldexp ] unit-test
{ 49152 } [ 12 12 ldexp ] unit-test
{ 0 } [ 12 -12 ldexp ] unit-test

{ 0.0 } [ 1 log ] unit-test
{ 0.0 } [ 1.0 log ] unit-test
{ 1.0 } [ e log ] unit-test

{ 0.0 } [ 1 e logn ] unit-test
{ 0.0 } [ 1.0 e logn ] unit-test
{ 1.0 } [ e e logn ] unit-test

CONSTANT: log-factorial-1000 0x1.71820d04e2eb6p12
CONSTANT: log10-factorial-1000 0x1.40f3593ed6f8ep11

{ $ log-factorial-1000 t } [ 1000 factorial [ log ] [ bignum? ] bi ] unit-test
{ C{ $ log-factorial-1000 $ pi } t } [ 1000 factorial neg [ log ] [ bignum? ] bi ] unit-test

{ 0.0 } [ 1.0 log10 ] unit-test
{ 1.0 } [ 10.0 log10 ] unit-test
{ 2.0 } [ 100.0 log10 ] unit-test
{ 3.0 } [ 1000.0 log10 ] unit-test
{ 4.0 } [ 10000.0 log10 ] unit-test
{ $ log10-factorial-1000 t } [ 1000 factorial [ log10 ] [ bignum? ] bi ] unit-test

{ f } [ 1 e^ 0/0. 1.e-10 ~ ] unit-test
{ f } [ 0/0. 1 e^ 1.e-10 ~ ] unit-test
{ f } [ 1/0. 1/0. 1.e-10 ~ ] unit-test
{ f } [ 1/0. -1/0. 1.e-10 ~ ] unit-test
{ f } [ 1/0. 0/0. 1.e-10 ~ ] unit-test
{ f } [ 0/0. -1/0. 1.e-10 ~ ] unit-test

{ e 1.e-10 } [ 1 e^ ] unit-test~
{ 1.0 1.e-10 } [ -1 e^ e * ] unit-test~

{ 0.0 } [ 0.0 e^-1 ] unit-test
{ -0.0 } [ -0.0 e^-1 ] unit-test
{ 1/0. } [ 1/0. e^-1 ] unit-test
{ -1.0 } [ -1/0. e^-1 ] unit-test
{ -1.0 } [ -1/0. e^-1 ] unit-test
{ t } [ NAN: 8000000000000 dup e^-1 [ fp-nan-payload ] same? ] unit-test
{ 5e-324 } [ 5e-324 e^-1 ] unit-test
{ 1e-20 } [ 1e-20 e^-1 ] unit-test
{ -5e-324 } [ -5e-324 e^-1 ] unit-test
{ -1e-20 } [ -1e-20 e^-1 ] unit-test
{ 1.0000000000500000e-10 } [ 1e-10 e^-1 ] unit-test
{ 22025.465794806718 } [ 10.0 e^-1 ] unit-test
{ -9.999999999500001e-11 } [ -1e-10 e^-1 ] unit-test
{ -0.9999546000702375 } [ -10.0 e^-1 ] unit-test
{ -1.0 } [ -38.0 e^-1 ] unit-test
{ -1.0 } [ -1e50 e^-1 ] unit-test
{ 1.9424263952412558e+130 } [ 300 e^-1 ] unit-test
{ 1.7976931346824240e+308 } [ 709.78271289328393 e^-1 ] unit-test
{ 1/0. } [ 1000.0 e^-1 ] unit-test
{ 1/0. } [ 1e50 e^-1 ] unit-test
{ 1/0. } [ 1.79e308 e^-1 ] unit-test

{ 1.0 } [ 0 cosh ] unit-test
{ 1.0 } [ 0.0 cosh ] unit-test
{ 0.0 } [ 1 acosh ] unit-test
{ 0.0 } [ 1.0 acosh ] unit-test

{ 1.0 } [ 0 cos ] unit-test
{ 1.0 } [ 0.0 cos ] unit-test
{ 0.0 } [ 1 acos ] unit-test
{ 0.0 } [ 1.0 acos ] unit-test

{ 0.0 } [ 0 sinh ] unit-test
{ 0.0 } [ 0.0 sinh ] unit-test
{ 0.0 } [ 0 asinh ] unit-test
{ 0.0 } [ 0.0 asinh ] unit-test

{ 0.0 } [ 0 sin ] unit-test
{ 0.0 } [ 0.0 sin ] unit-test
{ 0.0 } [ 0 asin ] unit-test
{ 0.0 } [ 0.0 asin ] unit-test

{ 0.0 } [ 0 tan ] unit-test
{ t } [ pi 2 / tan 1.e10 > ] unit-test

{ t } [ 10 atan real? ] unit-test
{ t } [ 10.0 atan real? ] unit-test
{ f } [ 10 atanh real? ] unit-test
{ f } [ 10.0 atanh real? ] unit-test

{ 10 1.e-10 } [ 10 asin sin ] unit-test~
{ -100 1.e-10 } [ -100 atan tan ] unit-test~
{ 10 1.e-10 } [ 10 asinh sinh ] unit-test~
{ 10 1.e-10 } [ 10 atanh tanh ] unit-test~
{ 0.5 1.e-10 } [ 0.5 atanh tanh ] unit-test~

{ t } [ -1 sqrt neg dup acos cos 1.e-10 ~ ] unit-test

{ t } [ 0 42 divisor? ] unit-test
{ t } [ 42 7 divisor? ] unit-test
{ t } [ 42 -7 divisor? ] unit-test
{ t } [ 42 42 divisor? ] unit-test
{ f } [ 42 16 divisor? ] unit-test

{ 3 } [ 5 7 mod-inv ] unit-test
{ 78572682077 } [ 234829342 342389423843 mod-inv ] unit-test

[ 2 10 mod-inv ] must-fail

{ t } [ 15 37 137 ^mod 15 37 ^ 137 mod = ] unit-test

{ t } [ 0 0 ^ fp-nan? ] unit-test
{ 1 } [ 10 0 ^ ] unit-test
{ 1/8 } [ 1/2 3 ^ ] unit-test
{ 1/8 } [ 2 -3 ^ ] unit-test
{ t } [ 1 100 shift 2 100 ^ = ] unit-test

{ 1 } [ 7/8 ceiling ] unit-test
{ 2 } [ 3/2 ceiling ] unit-test
{ 0 } [ -7/8 ceiling ] unit-test
{ -1 } [ -3/2 ceiling ] unit-test

{ 4.0 } [ 4.5 truncate ] unit-test
{ 4.0 } [ 4.5 floor ] unit-test
{ 5.0 } [ 4.5 ceiling ] unit-test

{ -4.0 } [ -4.5 truncate ] unit-test
{ -5.0 } [ -4.5 floor ] unit-test
{ -4.0 } [ -4.5 ceiling ] unit-test

{ t } [ -0.3 truncate double>bits 0.0 double>bits = ] unit-test
{ t } [ -0.3 ceiling double>bits -0.0 double>bits = ] unit-test
{ t } [ 0.3 floor double>bits 0.0 double>bits = ] unit-test
{ t } [ 0.3 truncate double>bits 0.0 double>bits = ] unit-test

{ -4.0 } [ -4.0 truncate ] unit-test
{ -4.0 } [ -4.0 floor ] unit-test
{ -4.0 } [ -4.0 ceiling ] unit-test

! first floats without fractional part
{ 0x1.0p52 } [ 0x1.0p52 truncate ] unit-test
{ 0x1.0000000000001p52 } [ 0x1.0000000000001p52 truncate ] unit-test
{ -0x1.0p52 } [ -0x1.0p52 truncate ] unit-test
{ -0x1.0000000000001p52 } [ -0x1.0000000000001p52 truncate ] unit-test

{ -5 } [ -9/2 round ] unit-test
{ -4 } [ -22/5 round ] unit-test
{ 5 } [ 9/2 round ] unit-test
{ 4 } [ 22/5 round ] unit-test

{ -5.0 } [ -4.5 round ] unit-test
{ -4.0 } [ -4.4 round ] unit-test
{ 5.0 } [ 4.5 round ] unit-test
{ 4.0 } [ 4.4 round ] unit-test

{ -1 } [ -3/5 round ] unit-test
{ -1 } [ -1/2 round ] unit-test
{ 0 } [ -2/5 round ] unit-test
{ 0 } [ 2/5 round ] unit-test
{ 1 } [ 1/2 round ] unit-test
{ 1 } [ 3/5 round ] unit-test

{ t } [ -0.3 round double>bits 0.0 double>bits = ] unit-test
{ t } [ 0.3 round double>bits 0.0 double>bits = ] unit-test

! A signaling NaN should raise an exception
! XXX: disabling to get linux32 binary
! HACK: bug in factor or in vmware?
! TODO: fix this test on linux32 vmware
!  { { +fp-invalid-operation+ } } [ [ NAN: 4000000000000 truncate drop ] collect-fp-exceptions ] unit-test
{ { +fp-invalid-operation+ } } [ [ NAN: 4000000000000 round drop ] collect-fp-exceptions ] unit-test
{ { +fp-invalid-operation+ } } [ [ NAN: 4000000000000 ceiling drop ] collect-fp-exceptions ] unit-test
{ { +fp-invalid-operation+ } } [ [ NAN: 4000000000000 floor drop ] collect-fp-exceptions ] unit-test

{ -5 } [ -4-3/5 round-to-even ] unit-test
{ -4 } [ -4-1/2 round-to-even ] unit-test
{ -4 } [ -4-2/5 round-to-even ] unit-test
{ 5 } [ 4+3/5 round-to-even ] unit-test
{ 4 } [ 4+1/2 round-to-even ] unit-test
{ 4 } [ 4+2/5 round-to-even ] unit-test
{ -5.0 } [ -4.6 round-to-even ] unit-test
{ -4.0 } [ -4.5 round-to-even ] unit-test
{ -4.0 } [ -4.4 round-to-even ] unit-test
{ 5.0 } [ 4.6 round-to-even ] unit-test
{ 4.0 } [ 4.5 round-to-even ] unit-test
{ 4.0 } [ 4.4 round-to-even ] unit-test

{ -5 } [ -4-3/5 round-to-odd ] unit-test
{ -5 } [ -4-1/2 round-to-odd ] unit-test
{ -4 } [ -4-2/5 round-to-odd ] unit-test
{ 5 } [ 4+3/5 round-to-odd ] unit-test
{ 5 } [ 4+1/2 round-to-odd ] unit-test
{ 4 } [ 4+2/5 round-to-odd ] unit-test
{ -5.0 } [ -4.6 round-to-odd ] unit-test
{ -5.0 } [ -4.5 round-to-odd ] unit-test
{ -4.0 } [ -4.4 round-to-odd ] unit-test
{ 5.0 } [ 4.6 round-to-odd ] unit-test
{ 5.0 } [ 4.5 round-to-odd ] unit-test
{ 4.0 } [ 4.4 round-to-odd ] unit-test

{ 6 59967 } [ 3837888 factor-2s ] unit-test
{ 6 -59967 } [ -3837888 factor-2s ] unit-test

{ 1 } [
    183009416410801897
    1067811677921310779
    2135623355842621559
    ^mod
] unit-test

{ 1 } [
    183009416410801897
    1067811677921310779
    2135623355842621559
    [ >bignum ] tri@ ^mod
] unit-test

{ 1.0  } [ 1.0 2.5 0.0 lerp ] unit-test
{ 2.5  } [ 1.0 2.5 1.0 lerp ] unit-test
{ 1.75 } [ 1.0 2.5 0.5 lerp ] unit-test

{ C{ 1 2 } } [ C{ 1 2 } 1 ^ ] unit-test

{ { t t t } } [
    3 3 roots {
        1.442249570307408
        C{ -0.7211247851537038 1.249024766483407 }
        C{ -0.7211247851537049 -1.249024766483406 }
    } [ .01 ~ ] 2map
] unit-test

{ t } [ 3 15 roots [ 15 ^ 3 .01 ~ ] all? ] unit-test

{ .5 } [ 0 sigmoid ] unit-test
{ t } [ 0 [ sigmoid logit ] keep .000001 ~ ] unit-test

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

[ -1 integer-sqrt ] must-fail
{ 0 } [ 0 integer-sqrt ] unit-test
{ 3 } [ 12 integer-sqrt ] unit-test
{ 4 } [ 16 integer-sqrt ] unit-test
{ 44 } [ 2019 integer-sqrt ] unit-test

[ -576460752303423489 integer-log10 ] [ positive-number-expected? ] must-fail-with
[ -123124 integer-log10 ] [ positive-number-expected? ] must-fail-with
[ -1/2 integer-log10 ] [ positive-number-expected? ] must-fail-with
[ 0 integer-log10 ] [ positive-number-expected? ] must-fail-with

{ 0 } [ 1 integer-log10 ] unit-test
{ 0 } [ 5 integer-log10 ] unit-test
{ 0 } [ 9 integer-log10 ] unit-test
{ 1 } [ 10 integer-log10 ] unit-test
{ 1 } [ 99 integer-log10 ] unit-test
{ 2 } [ 100 integer-log10 ] unit-test
{ 2 } [ 101 integer-log10 ] unit-test
{ 2 } [ 101 integer-log10 ] unit-test
{ 8 } [ 134217726 integer-log10 ] unit-test
{ 8 } [ 134217727 integer-log10 ] unit-test
{ 8 } [ 134217728 integer-log10 ] unit-test
{ 8 } [ 134217729 integer-log10 ] unit-test
{ 8 } [ 999999999 integer-log10 ] unit-test
{ 9 } [ 1000000000 integer-log10 ] unit-test
{ 9 } [ 1000000001 integer-log10 ] unit-test
{ 17 } [ 576460752303423486 integer-log10 ] unit-test
{ 17 } [ 576460752303423487 integer-log10 ] unit-test
{ 17 } [ 576460752303423488 integer-log10 ] unit-test
{ 17 } [ 576460752303423489 integer-log10 ] unit-test
{ 17 } [ 999999999999999999 integer-log10 ] unit-test
{ 18 } [ 1000000000000000000 integer-log10 ] unit-test
{ 18 } [ 1000000000000000001 integer-log10 ] unit-test
{ 999 } [ 1000 10^ 1 - integer-log10 ] unit-test
{ 1000 } [ 1000 10^ integer-log10 ] unit-test
{ 1000 } [ 1000 10^ 1 + integer-log10 ] unit-test

{ 0 } [ 9+1/2 integer-log10 ] unit-test
{ 1 } [ 10 integer-log10 ] unit-test
{ 1 } [ 10+1/2 integer-log10 ] unit-test
{ 999 } [ 1000 10^ 1/2 - integer-log10 ] unit-test
{ 1000 } [ 1000 10^ integer-log10 ] unit-test
{ 1000 } [ 1000 10^ 1/2 + integer-log10 ] unit-test
{ -1000 } [ 1000 10^ 1/2 - recip integer-log10 ] unit-test
{ -1000 } [ 1000 10^ recip integer-log10 ] unit-test
{ -1001 } [ 1000 10^ 1/2 + recip integer-log10 ] unit-test
{ -1 } [ 8/10 integer-log10 ] unit-test
{ -1 } [ 4/10 integer-log10 ] unit-test
{ -1 } [ 1/10 integer-log10 ] unit-test
{ -2 } [ 1/11 integer-log10 ] unit-test

{ 99 } [ 100 2^ 1/2 - integer-log2 ] unit-test
{ 100 } [ 100 2^ integer-log2 ] unit-test
{ 100 } [ 100 2^ 1/2 + integer-log2 ] unit-test
{ -100 } [ 100 2^ 1/2 - recip integer-log2 ] unit-test
{ -100 } [ 100 2^ recip integer-log2 ] unit-test
{ -101 } [ 100 2^ 1/2 + recip integer-log2 ] unit-test
{ -1 } [ 8/10 integer-log2 ] unit-test
{ -2 } [ 4/10 integer-log2 ] unit-test
{ -3 } [ 2/10 integer-log2 ] unit-test
{ -4 } [ 1/10 integer-log2 ] unit-test
