USING: kernel literals math math.parser sequences tools.test ;
IN: math.parser.tests

[ f ]
[ f string>number ]
unit-test

[ f ]
[ "12345abcdef" string>number ]
unit-test

[ t ]
[ "-12" string>number 0 < ]
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

[ 100000 ] [ "100,000" string>number ] unit-test

[ 100000.0 ] [ "100,000.0" string>number ] unit-test

[ f ] [ "," string>number ] unit-test
[ f ] [ "-," string>number ] unit-test
[ f ] [ "1," string>number ] unit-test
[ f ] [ "-1," string>number ] unit-test
[ f ] [ ",2" string>number ] unit-test
[ f ] [ "-,2" string>number ] unit-test

[ 2.0 ] [ "2." string>number ] unit-test

[ 255 ] [ "ff" hex> ] unit-test

[ "100.0" ]
[ "1.0e2" string>number number>string ]
unit-test

[ "-100.0" ]
[ "-1.0e2" string>number number>string ]
unit-test

[ "0.01" ]
[ "1.0e-2" string>number number>string ]
unit-test

[ "-0.01" ]
[ "-1.0e-2" string>number number>string ]
unit-test

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
[ "e/2" string>number ]
unit-test

[ f ] [ "12" bin> ] unit-test
[ f ] [ "fdsf" bin> ] unit-test
[ 3 ] [ "11" bin> ] unit-test

[ f ] [ "\0." string>number ] unit-test

[ 1 1 >base ] must-fail
[ 1 0 >base ] must-fail
[ 1 -1 >base ] must-fail

[ "0/0." ] [ 0.0 0.0 / number>string ] unit-test

[ "1/0." ] [ 1.0 0.0 / number>string ] unit-test

[ "-1/0." ] [ -1.0 0.0 / number>string ] unit-test

[ t ] [ "0/0." string>number fp-nan? ] unit-test

[ 1/0. ] [ "1/0." string>number ] unit-test

[ -1/0. ] [ "-1/0." string>number ] unit-test

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

[ 1.0 ] [ "1.0" hex> ] unit-test
[ 1.5 ] [ "1.8" hex> ] unit-test
[ 1.03125 ] [ "1.08" hex> ] unit-test
[ 15.5 ] [ "f.8" hex> ] unit-test
[ 15.53125 ] [ "f.88" hex> ] unit-test
[ -15.5 ] [ "-f.8" hex> ] unit-test
[ 15.5 ] [ "f.8p0" hex> ] unit-test
[ -15.5 ] [ "-f.8p0" hex> ] unit-test
[ 62.0 ] [ "f.8p2" hex> ] unit-test
[ 3.875 ] [ "f.8p-2" hex> ] unit-test
[ $[ 1 bits>double ] ] [ "1.0p-1074" hex> ] unit-test
[ 0.0 ] [ "1.0p-1075" hex> ] unit-test
[ 1/0. ] [ "1.0p1024" hex> ] unit-test
[ -1/0. ] [ "-1.0p1024" hex> ] unit-test

