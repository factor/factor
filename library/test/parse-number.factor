IN: temporary
USE: math
USE: parser
USE: strings
USE: test
USE: unparser

[ f ]
[ f parse-number ]
unit-test

[ f ]
[ "12345abcdef" parse-number ]
unit-test

[ t ]
[ "-12" parse-number 0 < ]
unit-test

[ f ]
[ "--12" parse-number ]
unit-test

[ f ]
[ "-" parse-number ]
unit-test

[ f ]
[ "e" parse-number ]
unit-test

[ "100.0" ]
[ "1.0e2" parse-number unparse ]
unit-test

[ "-100.0" ]
[ "-1.0e2" parse-number unparse ]
unit-test

[ "0.01" ]
[ "1.0e-2" parse-number unparse ]
unit-test

[ "-0.01" ]
[ "-1.0e-2" parse-number unparse ]
unit-test

[ f ]
[ "-1e-2e4" parse-number ]
unit-test

[ "3.14" ]
[ "3.14" parse-number unparse ]
unit-test

[ f ]
[ "." parse-number ]
unit-test

[ f ]
[ ".e" parse-number ]
unit-test

[ "101.0" ]
[ "1.01e2" parse-number unparse ]
unit-test

[ "-101.0" ]
[ "-1.01e2" parse-number unparse ]
unit-test

[ "1.01" ]
[ "101.0e-2" parse-number unparse ]
unit-test

[ "-1.01" ]
[ "-101.0e-2" parse-number unparse ]
unit-test

[ 5 ]
[ "10/2" parse-number ]
unit-test

[ -5 ]
[ "-10/2" parse-number ]
unit-test

[ -5 ]
[ "10/-2" parse-number ]
unit-test

[ 5 ]
[ "-10/-2" parse-number ]
unit-test

[ f ]
[ "10.0/2" parse-number ]
unit-test

[ f ]
[ "1e1/2" parse-number ]
unit-test

[ f ]
[ "e/2" parse-number ]
unit-test

[ "33/100" ]
[ "66/200" parse-number unparse ]
unit-test

[ "12" bin> ] unit-test-fails
[ "fdsf" bin> ] unit-test-fails
[ 3 ] [ "11" bin> ] unit-test
