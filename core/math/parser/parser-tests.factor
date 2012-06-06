USING: kernel literals math math.parser sequences tools.test ;
IN: math.parser.tests

[ f ]
[ f string>number ]
unit-test

[ f ]
[ ";" string>number ]
unit-test

[ f ]
[ "<>" string>number ]
unit-test

[ f ]
[ "^" string>number ]
unit-test

[ f ]
[ "789:;<=>?@" string>number ]
unit-test

[ f ]
[ "12345abcdef" string>number ]
unit-test

[ 12 ]
[ "+12" string>number ]
unit-test

[ -12 ]
[ "-12" string>number ]
unit-test

[ f ]
[ "-+12" string>number ]
unit-test

[ f ]
[ "+-12" string>number ]
unit-test

[ f ]
[ "--12" string>number ]
unit-test

[ f ]
[ "-" string>number ]
unit-test

[ f ]
[ "e" string>number ]
unit-test

[ 1/2 ] [ "1/2" string>number ] unit-test
[ -1/2 ] [ "-1/2" string>number ] unit-test
[ 2 ] [ "4/2" string>number ] unit-test
[ f ] [ "1/-2" string>number ] unit-test
[ f ] [ "1/2/3" string>number ] unit-test
[ 1+1/2 ] [ "1+1/2" string>number ] unit-test
[ 1+1/2 ] [ "+1+1/2" string>number ] unit-test
[ f ] [ "1-1/2" string>number ] unit-test
[ -1-1/2 ] [ "-1-1/2" string>number ] unit-test
[ f ] [ "-1+1/2" string>number ] unit-test
[ f ] [ "1+2" string>number ] unit-test
[ f ] [ "1+" string>number ] unit-test
[ f ] [ "1-" string>number ] unit-test
[ f ] [ "1+1/2+2" string>number ] unit-test

[ 100000 ] [ "100,000" string>number ] unit-test

[ 100000.0 ] [ "100,000.0" string>number ] unit-test

[ f ] [ "," string>number ] unit-test
[ f ] [ "-," string>number ] unit-test
[ f ] [ "1," string>number ] unit-test
[ f ] [ "-1," string>number ] unit-test
[ f ] [ ",2" string>number ] unit-test
[ f ] [ "-,2" string>number ] unit-test

[ 2.0 ] [ "2." string>number ] unit-test
[ 2.0 ] [ "+2." string>number ] unit-test
[ 0.25 ] [ ".25" string>number ] unit-test
[ -2.0 ] [ "-2." string>number ] unit-test
[ -0.25 ] [ "-.25" string>number ] unit-test
[ f ]  [ "-." string>number ] unit-test

[ 255 ] [ "ff" hex> ] unit-test

[ 100.0 ] [ "1.0e2" string>number ] unit-test
[ 100.0 ] [ "100.0" string>number ] unit-test
[ 100.0 ] [ "100." string>number ] unit-test

[ 100.0 ] [ "1e2" string>number ] unit-test
[ 100.0 ] [ "1e+2" string>number ] unit-test
[ 0x1e2 ] [ "1e2" hex> ] unit-test

[ 0x1.999999999999ap-3 ] [ "0.2" string>number ] unit-test
[ 0x1.3333333333333p0  ] [ "1.2" string>number ] unit-test
[ 0x1.5555555555555p0  ] [ "1.333,333,333,333,333,333" string>number ] unit-test
[ 0x1.aaaaaaaaaaaabp0  ] [ "1.666,666,666,666,666,666" string>number ] unit-test

[ "100.0" ]
[ "1.0e2" string>number number>string ]
unit-test

[ -100.0 ] [ "-1.0e2" string>number ] unit-test
[ -100.0 ] [ "-100.0" string>number ] unit-test
[ -100.0 ] [ "-100." string>number ] unit-test

[ "-100.0" ]
[ "-1.0e2" string>number number>string ]
unit-test

[ -100.0 ] [ "-1.e2" string>number ] unit-test

[ "0.01" ]
[ "1.0e-2" string>number number>string ]
unit-test

[ 0.01 ] [ "1.0e-2" string>number ] unit-test

[ "-0.01" ]
[ "-1.0e-2" string>number number>string ]
unit-test

[ -0.01 ] [ "-1.0e-2" string>number ] unit-test

[ "-0.01" ]
[ "-1.e-2" string>number number>string ]
unit-test

[ -1.0e-12 ] [ "-1.0e-12" string>number ] unit-test

[ t ]
[ "-1.0e-12" string>number number>string { "-1.0e-12" "-1.0e-012" } member? ]
unit-test

[ f ]
[ "-1e-2e4" string>number ]
unit-test

[ "3.14" ]
[ "3.14" string>number number>string ]
unit-test

[ f ]
[ "." string>number ]
unit-test
 
[ f ]
[ ".e" string>number ]
unit-test

[ "101.0" ]
[ "1.01e2" string>number number>string ]
unit-test

[ "-101.0" ]
[ "-1.01e2" string>number number>string ]
unit-test

[ "1.01" ]
[ "101.0e-2" string>number number>string ]
unit-test

[ "-1.01" ]
[ "-101.0e-2" string>number number>string ]
unit-test

[ f ]
[ "1e1/2" string>number ]
unit-test

[ f ]
[ "1e1.2" string>number ]
unit-test

[ f ]
[ "e/2" string>number ]
unit-test

[ f ] [ "12" bin> ] unit-test
[ f ] [ "fdsf" bin> ] unit-test
[ 3 ] [ "11" bin> ] unit-test

[ f ] [ "\0." string>number ] unit-test

[ 1 1 >base ] must-fail
[ 1 0 >base ] must-fail
[ 1 -1 >base ] must-fail
[ 2+1/2 -1 >base ] [ invalid-radix? ] must-fail-with
[ 123.456 8 >base ] [ invalid-base? ] must-fail-with
[ 123.456 2 >base ] [ invalid-base? ] must-fail-with

[ "0/0." ] [ 0.0 0.0 / number>string ] unit-test

[ "1/0." ] [ 1.0 0.0 / number>string ] unit-test

[ "-1/0." ] [ -1.0 0.0 / number>string ] unit-test

[ t ] [ "0/0." string>number fp-nan? ] unit-test

[ 1/0. ] [ "1/0." string>number ] unit-test

[ -1/0. ] [ "-1/0." string>number ] unit-test

[ -0.5 ] [ "-1/2." string>number ] unit-test

[ "-0.0" ] [ -0.0 number>string ] unit-test

[ "-3/4" ] [ -3/4 number>string ] unit-test
[ "-1-1/4" ] [ -5/4 number>string ] unit-test

[ "1.0p0" ] [ 1.0 >hex ] unit-test
[ "1.8p2" ] [ 6.0 >hex ] unit-test
[ "1.08p2" ] [ 4.125 >hex ] unit-test
[ "1.8p-2" ] [ 0.375 >hex ] unit-test
[ "-1.8p2" ] [ -6.0 >hex ] unit-test
[ "1.8p10" ] [ 1536.0 >hex ] unit-test
[ "0.0" ] [ 0.0 >hex ] unit-test
[ "1.0p-1074" ] [ 1 bits>double >hex ] unit-test
[ "-0.0" ] [ -0.0 >hex ] unit-test

[ 1.0 ] [ "1.0p0" hex> ] unit-test
[ 1.5 ] [ "1.8p0" hex> ] unit-test
[ 1.875 ] [ "1.ep0" hex> ] unit-test
[ 1.90625 ] [ "1.e8p0" hex> ] unit-test
[ 1.03125 ] [ "1.08p0" hex> ] unit-test
[ 15.5 ] [ "f.8p0" hex> ] unit-test
[ 15.53125 ] [ "f.88p0" hex> ] unit-test
[ -15.5 ] [ "-f.8p0" hex> ] unit-test
[ 15.5 ] [ "f.8p0" hex> ] unit-test
[ -15.5 ] [ "-f.8p0" hex> ] unit-test
[ 62.0 ] [ "f.8p2" hex> ] unit-test
[ 3.875 ] [ "f.8p-2" hex> ] unit-test
[ $[ 1 bits>double ] ] [ "1.0p-1074" hex> ] unit-test
[ 0.0 ] [ "1.0p-1075" hex> ] unit-test
[ 1/0. ] [ "1.0p1024" hex> ] unit-test
[ -1/0. ] [ "-1.0p1024" hex> ] unit-test

[ 0 ] [ "0" string>number ] unit-test
[ 0 ] [ "00" string>number ] unit-test
[ 0 ] [ "0,000" string>number ] unit-test
[ 0.0 ] [ "0." string>number ] unit-test
[ 0.0 ] [ "0.0" string>number ] unit-test
[ 0.0 ] [ "0x0.0p0" string>number ] unit-test
[ 0 ] [ "0x0" string>number ] unit-test
[ 0 ] [ "0o0" string>number ] unit-test
[ 0 ] [ "0b0" string>number ] unit-test

[ 10 ] [ "010" string>number ] unit-test
[ 16 ] [ "0x10" string>number ] unit-test
[  8 ] [ "0o10" string>number ] unit-test
[  2 ] [ "0b10" string>number ] unit-test

[ -10 ] [ "-010" string>number ] unit-test
[ -16 ] [ "-0x10" string>number ] unit-test
[  -8 ] [ "-0o10" string>number ] unit-test
[  -2 ] [ "-0b10" string>number ] unit-test

[ f ] [ "01a" string>number ] unit-test
[ f ] [ "0x1g" string>number ] unit-test
[ f ] [ "0o18" string>number ] unit-test
[ f ] [ "0b12" string>number ] unit-test

[ 11 ] [ "0x0b" string>number ] unit-test
[ f  ] [ "0x0o0" string>number ] unit-test

[ 0x7FFF,ABCD ] [ "0x7FFF,ABCD" string>number ] unit-test

[ 1.0 ] [ "0x1.0p0" string>number ] unit-test
[ 6.0 ] [ "0x1.8p2" string>number ] unit-test
[ 0.375 ] [ "0x1.8p-2" string>number ] unit-test
[ -6.0 ] [ "-0x1.8p2" string>number ] unit-test
[ -0.375 ] [ "-0x1.8p-2" string>number ] unit-test

[ f ] [ "0x" string>number ] unit-test
[ f ] [ "0b" string>number ] unit-test
[ f ] [ "0o" string>number ] unit-test
[ f ] [ "0x," string>number ] unit-test
[ f ] [ "0b," string>number ] unit-test
[ f ] [ "0o," string>number ] unit-test
[ f ] [ "0x,1" string>number ] unit-test
[ f ] [ "0b,1" string>number ] unit-test
[ f ] [ "0o,1" string>number ] unit-test
[ f ] [ "0x1," string>number ] unit-test
[ f ] [ "0b1," string>number ] unit-test
[ f ] [ "0o1," string>number ] unit-test

! #372
! hex float requires exponent
[ f ] [ "0x1.0" string>number ] unit-test

! hex float rounds to even on half
[ 0x1.0000,0000,0000,0p0 ] [ "0x1.0000,0000,0000,0,8p0" string>number ] unit-test
[ 0x1.0000,0000,0000,2p0 ] [ "0x1.0000,0000,0000,1,8p0" string>number ] unit-test
[ 0x1.0000,0000,0000,0p0 ] [ "0x8.0000,0000,0000,4p-3" string>number ] unit-test
[ 0x1.0000,0000,0000,2p0 ] [ "0x8.0000,0000,0000,Cp-3" string>number ] unit-test

[ -0x1.0000,0000,0000,0p0 ] [ "-0x1.0000,0000,0000,0,8p0" string>number ] unit-test
[ -0x1.0000,0000,0000,2p0 ] [ "-0x1.0000,0000,0000,1,8p0" string>number ] unit-test
[ -0x1.0000,0000,0000,0p0 ] [ "-0x8.0000,0000,0000,4p-3" string>number ] unit-test
[ -0x1.0000,0000,0000,2p0 ] [ "-0x8.0000,0000,0000,Cp-3" string>number ] unit-test

! hex float rounds to nearest with tiny epsilons
[ 0x1.0000,0000,0000,0p0 ] [ "0x1.0000,0000,0000,0,4p0" string>number ] unit-test
[ 0x1.0000,0000,0000,0p0 ] [ "0x1.0000,0000,0000,0,7Fp0" string>number ] unit-test
[ 0x1.0000,0000,0000,0p0 ] [ "0x1.0000,0000,0000,0,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

[ 0x1.0000,0000,0000,1p0 ] [ "0x1.0000,0000,0000,0,Cp0" string>number ] unit-test
[ 0x1.0000,0000,0000,1p0 ] [ "0x1.0000,0000,0000,0,81p0" string>number ] unit-test
[ 0x1.0000,0000,0000,1p0 ] [ "0x1.0000,0000,0000,0,8000,0000,0000,0001p0" string>number ] unit-test

[ 0x1.0000,0000,0000,1p0 ] [ "0x1.0000,0000,0000,1,4p0" string>number ] unit-test
[ 0x1.0000,0000,0000,1p0 ] [ "0x1.0000,0000,0000,1,7Fp0" string>number ] unit-test
[ 0x1.0000,0000,0000,1p0 ] [ "0x1.0000,0000,0000,1,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

[ 0x1.0000,0000,0000,2p0 ] [ "0x1.0000,0000,0000,1,Cp0" string>number ] unit-test
[ 0x1.0000,0000,0000,2p0 ] [ "0x1.0000,0000,0000,1,81p0" string>number ] unit-test
[ 0x1.0000,0000,0000,2p0 ] [ "0x1.0000,0000,0000,1,8000,0000,0000,0001p0" string>number ] unit-test

[ -0x1.0000,0000,0000,0p0 ] [ "-0x1.0000,0000,0000,0,4p0" string>number ] unit-test
[ -0x1.0000,0000,0000,0p0 ] [ "-0x1.0000,0000,0000,0,7Fp0" string>number ] unit-test
[ -0x1.0000,0000,0000,0p0 ] [ "-0x1.0000,0000,0000,0,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

[ -0x1.0000,0000,0000,1p0 ] [ "-0x1.0000,0000,0000,0,Cp0" string>number ] unit-test
[ -0x1.0000,0000,0000,1p0 ] [ "-0x1.0000,0000,0000,0,81p0" string>number ] unit-test
[ -0x1.0000,0000,0000,1p0 ] [ "-0x1.0000,0000,0000,0,8000,0000,0000,0001p0" string>number ] unit-test

[ -0x1.0000,0000,0000,1p0 ] [ "-0x1.0000,0000,0000,1,4p0" string>number ] unit-test
[ -0x1.0000,0000,0000,1p0 ] [ "-0x1.0000,0000,0000,1,7Fp0" string>number ] unit-test
[ -0x1.0000,0000,0000,1p0 ] [ "-0x1.0000,0000,0000,1,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

[ -0x1.0000,0000,0000,2p0 ] [ "-0x1.0000,0000,0000,1,Cp0" string>number ] unit-test
[ -0x1.0000,0000,0000,2p0 ] [ "-0x1.0000,0000,0000,1,81p0" string>number ] unit-test
[ -0x1.0000,0000,0000,2p0 ] [ "-0x1.0000,0000,0000,1,8000,0000,0000,0001p0" string>number ] unit-test

! #453
! hex> dec> oct> bin> shouldn't admit radix prefixes

[ 0x0b ] [ "0b" hex> ] unit-test
[ 0x0b0 ] [ "0b0" hex> ] unit-test
[ f ] [ "0o0" hex> ] unit-test
[ f ] [ "0x0" hex> ] unit-test

[ f ] [ "0b" dec> ] unit-test
[ f ] [ "0b0" dec> ] unit-test
[ f ] [ "0o0" dec> ] unit-test
[ f ] [ "0x0" dec> ] unit-test

[ f ] [ "0b" oct> ] unit-test
[ f ] [ "0b0" oct> ] unit-test
[ f ] [ "0o0" oct> ] unit-test
[ f ] [ "0x0" oct> ] unit-test

[ f ] [ "0b" bin> ] unit-test
[ f ] [ "0b0" bin> ] unit-test
[ f ] [ "0o0" bin> ] unit-test
[ f ] [ "0x0" bin> ] unit-test
