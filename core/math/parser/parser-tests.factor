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

{ t }
[ "-1.0e-12" string>number number>string { "-1.0e-12" "-1.0e-012" } member? ]
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
    33.4 "" 4 4 "f" "missing" format-float
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
