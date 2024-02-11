USING: kernel layouts literals math math.parser
math.parser.private sequences strings tools.test ;
IN: math.parser.tests

{ f }
[ f string>number ]
unit-test

{ f }
[ ";" string>number ]
unit-test

{ f }
[ "<>" string>number ]
unit-test

{ f }
[ "^" string>number ]
unit-test

{ f }
[ "789:;<=>?@" string>number ]
unit-test

{ f }
[ "12345abcdef" string>number ]
unit-test

{ 12 }
[ "+12" string>number ]
unit-test

{ -12 }
[ "-12" string>number ]
unit-test

{ f }
[ "-+12" string>number ]
unit-test

{ f }
[ "+-12" string>number ]
unit-test

{ f }
[ "--12" string>number ]
unit-test

{ f }
[ "-" string>number ]
unit-test

{ f }
[ "e" string>number ]
unit-test

{ f } [ "1/0" string>number ] unit-test
{ f } [ "-1/0" string>number ] unit-test
{ 1/2 } [ "1/2" string>number ] unit-test
{ -1/2 } [ "-1/2" string>number ] unit-test
{ 2 } [ "4/2" string>number ] unit-test
{ f } [ "1/-2" string>number ] unit-test
{ f } [ "1/2/3" string>number ] unit-test
{ 1+1/2 } [ "1+1/2" string>number ] unit-test
{ 1+1/2 } [ "+1+1/2" string>number ] unit-test
{ f } [ "1-1/2" string>number ] unit-test
{ -1-1/2 } [ "-1-1/2" string>number ] unit-test
{ f } [ "-1+1/2" string>number ] unit-test
{ f } [ "1+2" string>number ] unit-test
{ f } [ "1+" string>number ] unit-test
{ f } [ "1-" string>number ] unit-test
{ f } [ "1+1/2+2" string>number ] unit-test

{ 100000 } [ "100,000" string>number ] unit-test

{ 100000.0 } [ "100,000.0" string>number ] unit-test

{ f } [ "," string>number ] unit-test
{ f } [ "-," string>number ] unit-test
{ f } [ "1," string>number ] unit-test
{ f } [ "-1," string>number ] unit-test
{ f } [ ",2" string>number ] unit-test
{ f } [ "-,2" string>number ] unit-test

{ 2.0 } [ "2." string>number ] unit-test
{ 2.0 } [ "+2." string>number ] unit-test
{ 0.25 } [ ".25" string>number ] unit-test
{ -2.0 } [ "-2." string>number ] unit-test
{ -0.25 } [ "-.25" string>number ] unit-test
{ f }  [ "-." string>number ] unit-test

{ 255 } [ "ff" hex> ] unit-test

{ 100.0 } [ "1.0e2" string>number ] unit-test
{ 100.0 } [ "100.0" string>number ] unit-test
{ 100.0 } [ "100." string>number ] unit-test

{ 100.0 } [ "1e2" string>number ] unit-test
{ 100.0 } [ "1e+2" string>number ] unit-test
{ 0x1e2 } [ "1e2" hex> ] unit-test

{ 0x1.999999999999ap-3 } [ "0.2" string>number ] unit-test
{ 0x1.3333333333333p0  } [ "1.2" string>number ] unit-test
{ 0o1.146314631463146314p0 } [ "1.2" string>number ] unit-test
{ 0b1.0011001100110011001100110011001100110011001100110011p0 } [ "1.2" string>number ] unit-test
{ 0x1.5555555555555p0  } [ "1.333,333,333,333,333,333" string>number ] unit-test
{ 0x1.aaaaaaaaaaaabp0  } [ "1.666,666,666,666,666,666" string>number ] unit-test

{ "100.0" }
[ "1.0e2" string>number number>string ]
unit-test

{ -100.0 } [ "-1.0e2" string>number ] unit-test
{ -100.0 } [ "-100.0" string>number ] unit-test
{ -100.0 } [ "-100." string>number ] unit-test

{ "-100.0" }
[ "-1.0e2" string>number number>string ]
unit-test

{ -100.0 } [ "-1.e2" string>number ] unit-test

{ "0.01" }
[ "1.0e-2" string>number number>string ]
unit-test

{ 0.01 } [ "1.0e-2" string>number ] unit-test

{ "-0.01" }
[ "-1.0e-2" string>number number>string ]
unit-test

{ -0.01 } [ "-1.0e-2" string>number ] unit-test

{ "-0.01" }
[ "-1.e-2" string>number number>string ]
unit-test

{ -1.0e-12 } [ "-1.0e-12" string>number ] unit-test

{ "-0.000000000001" }
[ "-1.0e-12" string>number number>string ]
unit-test

{ f }
[ "-1e-2e4" string>number ]
unit-test

{ "3.14" }
[ "3.14" string>number number>string ]
unit-test

{ f }
[ "." string>number ]
unit-test

{ f }
[ ".e" string>number ]
unit-test

{ "101.0" }
[ "1.01e2" string>number number>string ]
unit-test

{ "-101.0" }
[ "-1.01e2" string>number number>string ]
unit-test

{ "1.01" }
[ "101.0e-2" string>number number>string ]
unit-test

{ "-1.01" }
[ "-101.0e-2" string>number number>string ]
unit-test

{ f }
[ "1e1/2" string>number ]
unit-test

{ f }
[ "1e1.2" string>number ]
unit-test

{ f }
[ "e/2" string>number ]
unit-test

{ f } [ "12" bin> ] unit-test
{ f } [ "fdsf" bin> ] unit-test
{ 3 } [ "11" bin> ] unit-test

{ f } [ "\0." string>number ] unit-test

[ 1 1 >base ] must-fail
[ 1 0 >base ] must-fail
[ 1 -1 >base ] must-fail
[ 2+1/2 -1 >base ] [ invalid-radix? ] must-fail-with
[ 123.456 7 >base ] [ invalid-radix? ] must-fail-with

{  "0/0." } [  0/0. number>string ] unit-test
{ "-0/0." } [ -0/0. number>string ] unit-test

{ t } [  "0/0." string>number fp-nan? ] unit-test
{ t } [ "-0/0." string>number fp-nan? ] unit-test

{ f } [  "0/0." string>number fp-sign ] unit-test
{ t } [ "-0/0." string>number fp-sign ] unit-test


{ "1/0." } [ 1/0. number>string ] unit-test
{ 1/0. } [ "1/0." string>number ] unit-test

{ "-1/0." } [ -1/0. number>string ] unit-test
{ -1/0. } [ "-1/0." string>number ] unit-test

{ -0.5 } [ "-1/2." string>number ] unit-test

{ "-0.0" } [ -0.0 number>string ] unit-test

{ "-3/4" } [ -3/4 number>string ] unit-test
{ "-1-1/4" } [ -5/4 number>string ] unit-test

{ "1.0p0" } [ 1.0 >hex ] unit-test
{ "1.8p2" } [ 6.0 >hex ] unit-test
{ "1.08p2" } [ 4.125 >hex ] unit-test
{ "1.8p-2" } [ 0.375 >hex ] unit-test
{ "-1.8p2" } [ -6.0 >hex ] unit-test
{ "1.8p10" } [ 1536.0 >hex ] unit-test
{ "0.0" } [ 0.0 >hex ] unit-test
{ "1.0p-1074" } [ 1 bits>double >hex ] unit-test
{ "-0.0" } [ -0.0 >hex ] unit-test

{ "1.0p0" } [ 1.0 >bin ] unit-test
{ "1.1p2" } [ 6.0 >bin ] unit-test
{ "1.00001p2" } [ 4.125 >bin ] unit-test
{ "1.1p-2" } [ 0.375 >bin ] unit-test
{ "-1.1p2" } [ -6.0 >bin ] unit-test
{ "1.1p10" } [ 1536.0 >bin ] unit-test
{ "0.0" } [ 0.0 >bin ] unit-test
{ "1.0p-1074" } [ 1 bits>double >bin ] unit-test
{ "-0.0" } [ -0.0 >bin ] unit-test

{ "1.0p0" } [ 1.0 >oct ] unit-test
{ "1.4p2" } [ 6.0 >oct ] unit-test
{ "1.02p2" } [ 4.125 >oct ] unit-test
{ "1.4p-2" } [ 0.375 >oct ] unit-test
{ "-1.4p2" } [ -6.0 >oct ] unit-test
{ "1.4p10" } [ 1536.0 >oct ] unit-test
{ "0.0" } [ 0.0 >oct ] unit-test
{ "1.0p-1074" } [ 1 bits>double >oct ] unit-test
{ "-0.0" } [ -0.0 >oct ] unit-test

{ 1.0 } [ "1.0p0" hex> ] unit-test
{ 1.5 } [ "1.8p0" hex> ] unit-test
{ 1.875 } [ "1.ep0" hex> ] unit-test
{ 1.90625 } [ "1.e8p0" hex> ] unit-test
{ 1.03125 } [ "1.08p0" hex> ] unit-test
{ 15.5 } [ "f.8p0" hex> ] unit-test
{ 15.53125 } [ "f.88p0" hex> ] unit-test
{ -15.5 } [ "-f.8p0" hex> ] unit-test
{ 15.5 } [ "f.8p0" hex> ] unit-test
{ -15.5 } [ "-f.8p0" hex> ] unit-test
{ 62.0 } [ "f.8p2" hex> ] unit-test
{ 3.875 } [ "f.8p-2" hex> ] unit-test
{ $[ 1 bits>double ] } [ "1.0p-1074" hex> ] unit-test
{ 0.0 } [ "1.0p-1075" hex> ] unit-test
{ 1/0. } [ "1.0p1024" hex> ] unit-test
{ -1/0. } [ "-1.0p1024" hex> ] unit-test

{ 1.0 } [ "1.0p0" bin> ] unit-test
{ 1.5 } [ "1.1p0" bin> ] unit-test
{ 1.875 } [ "1.111p0" bin> ] unit-test
{ 1.90625 } [ "1.11101p0" bin> ] unit-test
{ 1.03125 } [ "1.00001p0" bin> ] unit-test
{ 15.5 } [ "1111.1p0" bin> ] unit-test
{ 15.53125 } [ "1111.10001p0" bin> ] unit-test
{ -15.5 } [ "-1111.1p0" bin> ] unit-test
{ 15.5 } [ "1111.1p0" bin> ] unit-test
{ -15.5 } [ "-1111.1p0" bin> ] unit-test
{ 62.0 } [ "1111.1p2" bin> ] unit-test
{ 3.875 } [ "1111.1p-2" bin> ] unit-test
{ $[ 1 bits>double ] } [ "1.0p-1074" bin> ] unit-test
{ 0.0 } [ "1.0p-1075" bin> ] unit-test
{ 1/0. } [ "1.0p1024" bin> ] unit-test
{ -1/0. } [ "-1.0p1024" bin> ] unit-test

{ 1.0 } [ "1.0p0" oct> ] unit-test
{ 1.5 } [ "1.4p0" oct> ] unit-test
{ 1.875 } [ "1.7p0" oct> ] unit-test
{ 1.90625 } [ "1.72p0" oct> ] unit-test
{ 1.03125 } [ "1.02p0" oct> ] unit-test
{ 15.5 } [ "17.4p0" oct> ] unit-test
{ 15.53125 } [ "17.42p0" oct> ] unit-test
{ -15.5 } [ "-17.4p0" oct> ] unit-test
{ 15.5 } [ "17.4p0" oct> ] unit-test
{ -15.5 } [ "-17.4p0" oct> ] unit-test
{ 62.0 } [ "17.4p2" oct> ] unit-test
{ 3.875 } [ "17.4p-2" oct> ] unit-test
{ $[ 1 bits>double ] } [ "1.0p-1074" oct> ] unit-test
{ 0.0 } [ "1.0p-1075" oct> ] unit-test
{ 1/0. } [ "1.0p1024" oct> ] unit-test
{ -1/0. } [ "-1.0p1024" oct> ] unit-test

{ 0 } [ "0" string>number ] unit-test
{ 0 } [ "00" string>number ] unit-test
{ 0 } [ "0,000" string>number ] unit-test
{ 0.0 } [ "0." string>number ] unit-test
{ 0.0 } [ "0.0" string>number ] unit-test
{ 0.0 } [ "0x0.0p0" string>number ] unit-test
{ 0 } [ "0x0" string>number ] unit-test
{ 0 } [ "0o0" string>number ] unit-test
{ 0 } [ "0b0" string>number ] unit-test

{ 10 } [ "010" string>number ] unit-test
{ 16 } [ "0x10" string>number ] unit-test
{  8 } [ "0o10" string>number ] unit-test
{  2 } [ "0b10" string>number ] unit-test

{ -10 } [ "-010" string>number ] unit-test
{ -16 } [ "-0x10" string>number ] unit-test
{  -8 } [ "-0o10" string>number ] unit-test
{  -2 } [ "-0b10" string>number ] unit-test

{ 16 } [ "0X10" string>number ] unit-test
{  8 } [ "0O10" string>number ] unit-test
{  2 } [ "0B10" string>number ] unit-test

{ -16 } [ "-0X10" string>number ] unit-test
{  -8 } [ "-0O10" string>number ] unit-test
{  -2 } [ "-0B10" string>number ] unit-test

{ f } [ "01a" string>number ] unit-test
{ f } [ "0x1g" string>number ] unit-test
{ f } [ "0o18" string>number ] unit-test
{ f } [ "0b12" string>number ] unit-test

{ 11 } [ "0x0b" string>number ] unit-test
{ f  } [ "0x0o0" string>number ] unit-test

{ 0x7FFF,ABCD } [ "0x7FFF,ABCD" string>number ] unit-test

{ 1.0 } [ "0x1.0p0" string>number ] unit-test
{ 6.0 } [ "0x1.8p2" string>number ] unit-test
{ 0.375 } [ "0x1.8p-2" string>number ] unit-test
{ -6.0 } [ "-0x1.8p2" string>number ] unit-test
{ -0.375 } [ "-0x1.8p-2" string>number ] unit-test

{ f } [ "0x" string>number ] unit-test
{ f } [ "0b" string>number ] unit-test
{ f } [ "0o" string>number ] unit-test
{ f } [ "0x," string>number ] unit-test
{ f } [ "0b," string>number ] unit-test
{ f } [ "0o," string>number ] unit-test
{ f } [ "0x,1" string>number ] unit-test
{ f } [ "0b,1" string>number ] unit-test
{ f } [ "0o,1" string>number ] unit-test
{ f } [ "0x1," string>number ] unit-test
{ f } [ "0b1," string>number ] unit-test
{ f } [ "0o1," string>number ] unit-test

{ f } [ "1_" string>number ] unit-test
{ 12 } [ "1_2" string>number ] unit-test
{ f } [ "1_2_" string>number ] unit-test
{ 123 } [ "1_2_3" string>number ] unit-test

! #372
! hex float requires exponent
{ f } [ "0x1.0" string>number ] unit-test

! hex float rounds to even on half
{ 0x1.0000,0000,0000,0p0 } [ "0x1.0000,0000,0000,0,8p0" string>number ] unit-test
{ 0x1.0000,0000,0000,2p0 } [ "0x1.0000,0000,0000,1,8p0" string>number ] unit-test
{ 0x1.0000,0000,0000,0p0 } [ "0x8.0000,0000,0000,4p-3" string>number ] unit-test
{ 0x1.0000,0000,0000,2p0 } [ "0x8.0000,0000,0000,Cp-3" string>number ] unit-test

{ -0x1.0000,0000,0000,0p0 } [ "-0x1.0000,0000,0000,0,8p0" string>number ] unit-test
{ -0x1.0000,0000,0000,2p0 } [ "-0x1.0000,0000,0000,1,8p0" string>number ] unit-test
{ -0x1.0000,0000,0000,0p0 } [ "-0x8.0000,0000,0000,4p-3" string>number ] unit-test
{ -0x1.0000,0000,0000,2p0 } [ "-0x8.0000,0000,0000,Cp-3" string>number ] unit-test

! hex float rounds to nearest with tiny epsilons
{ 0x1.0000,0000,0000,0p0 } [ "0x1.0000,0000,0000,0,4p0" string>number ] unit-test
{ 0x1.0000,0000,0000,0p0 } [ "0x1.0000,0000,0000,0,7Fp0" string>number ] unit-test
{ 0x1.0000,0000,0000,0p0 } [ "0x1.0000,0000,0000,0,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

{ 0x1.0000,0000,0000,1p0 } [ "0x1.0000,0000,0000,0,Cp0" string>number ] unit-test
{ 0x1.0000,0000,0000,1p0 } [ "0x1.0000,0000,0000,0,81p0" string>number ] unit-test
{ 0x1.0000,0000,0000,1p0 } [ "0x1.0000,0000,0000,0,8000,0000,0000,0001p0" string>number ] unit-test

{ 0x1.0000,0000,0000,1p0 } [ "0x1.0000,0000,0000,1,4p0" string>number ] unit-test
{ 0x1.0000,0000,0000,1p0 } [ "0x1.0000,0000,0000,1,7Fp0" string>number ] unit-test
{ 0x1.0000,0000,0000,1p0 } [ "0x1.0000,0000,0000,1,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

{ 0x1.0000,0000,0000,2p0 } [ "0x1.0000,0000,0000,1,Cp0" string>number ] unit-test
{ 0x1.0000,0000,0000,2p0 } [ "0x1.0000,0000,0000,1,81p0" string>number ] unit-test
{ 0x1.0000,0000,0000,2p0 } [ "0x1.0000,0000,0000,1,8000,0000,0000,0001p0" string>number ] unit-test

{ -0x1.0000,0000,0000,0p0 } [ "-0x1.0000,0000,0000,0,4p0" string>number ] unit-test
{ -0x1.0000,0000,0000,0p0 } [ "-0x1.0000,0000,0000,0,7Fp0" string>number ] unit-test
{ -0x1.0000,0000,0000,0p0 } [ "-0x1.0000,0000,0000,0,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

{ -0x1.0000,0000,0000,1p0 } [ "-0x1.0000,0000,0000,0,Cp0" string>number ] unit-test
{ -0x1.0000,0000,0000,1p0 } [ "-0x1.0000,0000,0000,0,81p0" string>number ] unit-test
{ -0x1.0000,0000,0000,1p0 } [ "-0x1.0000,0000,0000,0,8000,0000,0000,0001p0" string>number ] unit-test

{ -0x1.0000,0000,0000,1p0 } [ "-0x1.0000,0000,0000,1,4p0" string>number ] unit-test
{ -0x1.0000,0000,0000,1p0 } [ "-0x1.0000,0000,0000,1,7Fp0" string>number ] unit-test
{ -0x1.0000,0000,0000,1p0 } [ "-0x1.0000,0000,0000,1,7FFF,FFFF,FFFF,FFFFp0" string>number ] unit-test

{ -0x1.0000,0000,0000,2p0 } [ "-0x1.0000,0000,0000,1,Cp0" string>number ] unit-test
{ -0x1.0000,0000,0000,2p0 } [ "-0x1.0000,0000,0000,1,81p0" string>number ] unit-test
{ -0x1.0000,0000,0000,2p0 } [ "-0x1.0000,0000,0000,1,8000,0000,0000,0001p0" string>number ] unit-test

! #453
! hex> dec> oct> bin> shouldn't admit radix prefixes

{ 0x0b } [ "0b" hex> ] unit-test
{ 0x0b0 } [ "0b0" hex> ] unit-test
{ f } [ "0o0" hex> ] unit-test
{ f } [ "0x0" hex> ] unit-test

{ f } [ "0b" dec> ] unit-test
{ f } [ "0b0" dec> ] unit-test
{ f } [ "0o0" dec> ] unit-test
{ f } [ "0x0" dec> ] unit-test

{ f } [ "0b" oct> ] unit-test
{ f } [ "0b0" oct> ] unit-test
{ f } [ "0o0" oct> ] unit-test
{ f } [ "0x0" oct> ] unit-test

{ f } [ "0b" bin> ] unit-test
{ f } [ "0b0" bin> ] unit-test
{ f } [ "0o0" bin> ] unit-test
{ f } [ "0x0" bin> ] unit-test

! #1229, float parsing bug, and a regression
{ -0.5 } [ "-.5" dec> ] unit-test
{ 0 } [ "0" hex> ] unit-test

{ t } [ most-positive-fixnum number>string string>number fixnum? ] unit-test
{ t } [ most-negative-fixnum number>string string>number fixnum? ] unit-test

! large/small numbers/exponents correctly cancel out
{ 1.0 } [ "1" 3000 [ CHAR: 0 ] "" replicate-as append "e-3000" append string>number ] unit-test
{ 1.0 } [ "0x1" 1000 [ CHAR: 0 ] "" replicate-as append "p-4000" append string>number ] unit-test
{ 1.0 } [ "0." 3000 [ CHAR: 0 ] "" replicate-as append "1e3001" append string>number ] unit-test
{ 1.0 } [ "0x0." 1000 [ CHAR: 0 ] "" replicate-as append "1p4004" append string>number ] unit-test
{ 1.0 } [ "1" 3000 [ CHAR: 0 ] "" replicate-as append "." append
              3000 [ CHAR: 0 ] "" replicate-as append "e-3000" append string>number ] unit-test

! We correctly parse the biggest/smallest float correctly
! (ie the 1/0. or 0/0. short-circuit optimization doesn't apply)
{ 1 } [ "4.9406564584124655e-324" string>number double>bits ] unit-test
{ 1 } [ "0x1.0p-1074" string>number double>bits ] unit-test
{ 1 } [ "0o1.0p-1074" string>number double>bits ] unit-test
{ 1 } [ "0b1.0p-1074" string>number double>bits ] unit-test
{ 0x7fefffffffffffff } [ "1.7976931348623157e+308" string>number double>bits ] unit-test
{ 0x7fefffffffffffff } [ "0x1.fffffffffffffp1023" string>number double>bits ] unit-test
{ 0x7fefffffffffffff } [ "0o1.777777777777777774p1023" string>number double>bits ] unit-test
{ 0x7fefffffffffffff } [ "0b1.1111111111111111111111111111111111111111111111111111p1023" string>number double>bits ] unit-test
! Actual biggest/smallest parseable floats are a little
! larger/smaller than IEE754 values because of rounding
{ 0x1.0p-1074 } [ "0x0.fffffffffffffcp-1074" string>number ] unit-test
{ 4.94065645841246544e-324 } [ "4.94065645841246517e-324" string>number ] unit-test
{ 0x1.fffffffffffffp1023 } [ "0x1.fffffffffffff7ffffffffffffffffp1023" string>number ] unit-test
{ 1.79769313486231571e+308 } [ "1.797693134862315807e+308" string>number ] unit-test

! works with ratios
{ 0.25 } [ "1/4" 3000 [ CHAR: 0 ] "" replicate-as append "e-3000" append string>number ] unit-test
! XXX: disable for right now, see #1362 or #1408
! { 1.25 } [ "1+1/4" 3000 [ CHAR: 0 ] "" replicate-as append "e-3000" append string>number ] unit-test

! #1356 #1231
{ 1/0. } [ "1e100000" string>number ] unit-test
{ 0.0  } [ "1e-100000" string>number ] unit-test
{ 1/0. } [ "0x1p300000" string>number ] unit-test
{ 0.0  } [ "0x1p-300000" string>number ] unit-test

{ "deadbeef" } [ B{ 222 173 190 239 } bytes>hex-string ] unit-test
{ B{ 222 173 190 239 } } [ "deADbeEF" hex-string>bytes ] unit-test

{
    B{ 49 46 53 53 69 43 48 53 }
} [
    155000.0 B{ 0 } -1 3 B{ 69 0 } B{ 67 0 } (format-float)
] unit-test

{
    B{ 32 32 32 32 32 32 32 49 46 53 53 69 43 48 53 }
} [
    155000.0 B{ 0 } 15 3 B{ 69 0 } B{ 67 0 } (format-float)
] unit-test

! Missing locale
{ "" } [
    33.4 "" 4 4 "f" "missing" format-float*
] unit-test

! Literal byte arrays are mutable, so (format-float) isn't foldable.
: trouble ( -- str ba )
    155000.0 B{ } -1 3 B{ 69 0 } [
        B{ 67 0 } (format-float) >string
    ] keep ;

{
    "1.55E+05"
    "1.550e+05"
} [
    trouble CHAR: e 0 rot set-nth trouble drop
] unit-test

{ "143.99999999999997" } [ 0x1.1ffffffffffffp7 number>string ] unit-test
{ "144.0" } [ 0x1.2p7 number>string ] unit-test
{ "144.00000000000003" } [ 0x1.2000000000001p7 number>string ] unit-test

{ 0x80000000000000000000000000000000 } [ 0 φ ] unit-test

{
    ! edgecases
    {                  20     0                   "1e-322"  }
    {                   1     0                   "5e-324"  }
    {  0x000fffffffffffff     0   "2.225073858507201e-308"  }
    {                   0     1  "2.2250738585072014e-308"  }
    {                   1     1   "2.225073858507202e-308"  }
    {  0x000fffffffffffff     1  "4.4501477170144023e-308"  }
    {                   0     2   "4.450147717014403e-308"  }
    {                   1     2   "4.450147717014404e-308"  }
    {                   0     4  "1.7800590868057611e-307"  }
    {                   0     5  "3.5601181736115222e-307"  }
    {                   0     6   "7.120236347223045e-307"  }
    {                   0    10  "1.1392378155556871e-305"  }
    {  0x000ffffffffffffe  2046   "1.7976931348623155e308"  }
    {  0x000fffffffffffff  2046   "1.7976931348623157e308"  }

    ! stress tests, < 1/2 ulp
    {  4007430392905160   733                  "9.5e-88"  }
    {   698388779696245   251                "4.65e-233"  }
    {  1903293320899403  1312                 "1.415e87"  }
    {  3927554571361996  1147                "3.9815e37"  }
    {  1971449568774091  1174               "4.10405e45"  }
    {  3770707915602346  1801             "2.920845e234"  }
    {   877465856894836   619           "2.8919465e-122"  }
    {  2258128958129238    18          "4.37877185e-303"  }
    {  3472938851240260  1451          "1.227701635e129"  }
    {  1478804231587571  1452         "1.8415524525e129"  }
    {  1033395563260341  1168         "5.48357443505e43"  }
    {  2721851261911698  1785       "3.891901811465e229"  }
    {  2721851261911698  1784      "1.9459509057325e229"  }
    {  4199773113776883  1192      "1.44609583816055e51"  }
    {  4440663047904721    74   "4.173677474585315e-286"  }
    {  2956204068717196   368  "1.1079507728788885e-197"  }
    {  1576869389299883   694    "1.234550136632744e-99"  }
    {  3881915519664261  1796     "9.25031711960365e232"  }
    {  3010617184019290   247    "4.19804715028489e-234"  }
    {  3893698175890015   730   "1.1716315319786511e-88"  }
    {  2229859611940047  1277     "4.328100728446125e76"  }
    {  3587850959922298   602   "3.317710118160031e-127"  }

    ! stress tests, > 1/2 ulp
    {  2063659254706906  2027                  "2.5e302"  }
    {  2209131796074438  1610                 "7.55e176"  }
    {  2209131796074438  1609                "3.775e176"  }
    {   794805784202541   118              "4.3495e-273"  }
    {   633711540289011   931              "2.30365e-28"  }
    {  2218681082291372  1438             "1.263005e125"  }
    {   840836770664431   906            "7.1422105e-36"  }
    {  3865523976906785   222          "1.39345735e-241"  }
    {  4492222481117167   295         "1.414634485e-219"  }
    {  4439233208194286   692        "4.5392779195e-100"  }
    {  4439233208194286   691       "2.26963895975e-100"  }
    {  4439233208194286   690      "1.134819479875e-100"  }
    {  2462349842116650   826      "7.7003665618895e-60"  }
    {  2462349842116650   825     "3.85018328094475e-60"  }
    {  2462349842116650   824    "1.925091640472375e-60"  }
    {  2983653093616330  1623   "6.8985865317742005e180"  }
    {  1088518052258015  1239    "1.3076622631878654e65"  }
    {  4383455621985292  1740   "1.3605202075612124e216"  }
    {  2490587845261953  1765   "3.5928102174759597e223"  }
    {  4293976951641647  1663    "8.912519771248455e192"  }
    {  2859727106134841  1347    "5.5876975736230114e97"  }
    {  4045897783924006   627  "1.1762578307285404e-119"  }
} [| tuple |
    tuple first3 :> ( F E str )
    { str } [ "" F E dragonbox general-format ] unit-test
] each

{
    ! regression tests
    {   1.5745340942675811e257    "1.574534094267581e257"  }
    {  1.6521200219181297e-180  "1.6521200219181297e-180"  }
    {  4.6663180925160944e-302  "4.6663180925160944e-302"  }
    {    2.0919495182368195e19    "2.0919495182368195e19"  }
    {    2.6760179287532483e19    "2.6760179287532483e19"  }
    {    3.2942957306323907e19    "3.2942957306323907e19"  }
    {    3.9702293349085635e19    "3.9702293349085635e19"  }
    {    4.0647939013152195e19    "4.0647939013152195e19"  }
    {    1.8014398509481984e16    "1.8014398509481984e16"  }
    {    1.8014398509481985e16    "1.8014398509481984e16"  }

    ! rounding tests
    {      1.00000000000000005                      "1.0"  }
    {      1.00000000000000015       "1.0000000000000002"  }
    {      1.99999999999999985       "1.9999999999999998"  }
    {      1.99999999999999995                      "2.0"  }
    {      1125899906842623.75       "1125899906842623.8"  }
    {      1125899906842624.25       "1125899906842624.2"  }
    {       562949953421312.25        "562949953421312.2"  }
    {      2.20781707763671875       "2.2078170776367188"  }
    {      1.81835174560546875       "1.8183517456054688"  }
    {      3.94171905517578125       "3.9417190551757812"  }
    {      3.73860931396484375       "3.7386093139648438"  }
    {      3.96773529052734375       "3.9677352905273438"  }
    {      1.32802581787109375       "1.3280258178710938"  }
    {      3.92096710205078125       "3.9209671020507812"  }
    {      1.01523590087890625       "1.0152359008789062"  }
    {      1.33522796630859375       "1.3352279663085938"  }
    {      1.34452056884765625       "1.3445205688476562"  }
    {      2.87912750244140625       "2.8791275024414062"  }
    {      3.69583892822265625       "3.6958389282226562"  }
    {      1.84534454345703125       "1.8453445434570312"  }
    {      3.79395294189453125       "3.7939529418945312"  }
    {      3.21140289306640625       "3.2114028930664062"  }
    {      2.56597137451171875       "2.5659713745117188"  }
    {      0.96515655517578125       "0.9651565551757812"  }
    {      2.70000457763671875       "2.7000045776367188"  }
    {      0.76709747314453125       "0.7670974731445312"  }
    {      1.78044891357421875       "1.7804489135742188"  }
    {      2.62483978271484375       "2.6248397827148438"  }
    {      1.30529022216796875       "1.3052902221679688"  }
    {      3.83492279052734375       "3.8349227905273438"  }

    ! integer tests
    {                 1.0                 "1.0"  }
    {                10.0                "10.0"  }
    {               100.0               "100.0"  }
    {              1000.0              "1000.0"  }
    {             10000.0             "10000.0"  }
    {            100000.0            "100000.0"  }
    {           1000000.0           "1000000.0"  }
    {          10000000.0          "10000000.0"  }
    {         100000000.0         "100000000.0"  }
    {        1000000000.0        "1000000000.0"  }
    {       10000000000.0       "10000000000.0"  }
    {      100000000000.0      "100000000000.0"  }
    {     1000000000000.0     "1000000000000.0"  }
    {    10000000000000.0    "10000000000000.0"  }
    {   100000000000000.0   "100000000000000.0"  }
    {  1000000000000000.0  "1000000000000000.0"  }
    {  9007199254740000.0  "9007199254740000.0"  }
    {  9007199254740992.0  "9007199254740992.0"  }
    {                1e22                "1e22"  }
    {                1e23                "1e23"  }
} [| tuple |
    tuple first2 :> ( n str )
    { str } [ n format-float ] unit-test
] each

{
    ! regression tests
     6.1734402962680736e199
    2.4400113864427797e-153
     5.2632699518024996e199
     5.0806205262434145e252
     6.7785205636751565e118
    1.1240911411101675e-251
      8.139240250313929e194
     4.8614002257993364e178
      2.752696193128505e129
    3.1770556126883376e-271
     2.242759017628732e-248
     1.7802970329193148e-77
      3.806109028477244e187
     1.1848198569896827e213
    2.9391656381652973e-100
         6.424228912347e278
     1.2645752114230544e236
      8.42515920555967e-234
      2.7329003323103567e46
     1.3794281777002848e132
     1.7142202471499735e280
      9.634269789762257e200
      8.083700236068939e-82
     1.5588992945750237e163
    1.0074862449311154e-133
     3.1674528983750413e156
     1.8663368017075642e168
     2.7789467828287196e-24
     1.3816831617696479e116
     8.197561614832019e-114
    1.7020441232782313e-247
    4.1401971003386077e-194
    1.5769408597238478e-194
     3.3471805328331117e299
      5.529329422375565e-66
    1.6103234499457023e-135
    2.9198565218330256e-280
      8.038156131293134e163
    1.3920716328733164e-171
      6.827324062276435e-27
      8.807592735347699e-71
    3.3728552641313123e-123
     2.4122679021903798e236
     8.266944620606866e-263
     2.7137385859318285e105
      1.863720230324117e232
      7.972905225864674e-54
     2.2844314792315022e125
      9.70790738880233e-169
      1.2665834799024419e44
     3.3484409434495807e284
      1.3582268200372764e84
    3.4534664118884534e-136
      9.035819340849007e181
     2.0437259151405597e174
     9.859326049199017e-251
     1.3201219024272826e162
      1.3893748715780833e65
       6.447847606411378e49
       5.465125341473931e80
} [| n |
    { n } [ n format-float dec> ] unit-test
] each

{
    ! regression tests
    0x38FB2D4A60898DAB
    0x453F265980DCB674
    0x0A4FB5016FF839C0
    0x38F1C98B4F73D69C
    0x1F8D0A0A25B8C46D
    0x4361B4CCC78673FD
    0x43C3F516F5C2AE90
    0x4386C73EFAE567DA
    0x471F25D5F53ACB9B
    0x459AF3D7E7CDDDFF
    0x465D1C534CC2368F
    0x455FCEB5B44D932F
    0x45B5C534DA985042
} [| n |
    { n } [ n bits>double format-float dec> double>bits ]
    unit-test
] each
