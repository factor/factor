IN: temporary
USING: errors kernel math parser sequences test ;

: parse-number ( str -- num )
    #! Convert a string to a number; return f on error.
    [ string>number ] catch [ drop f ] when ;

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
[ "1.0e2" parse-number number>string ]
unit-test

[ "-100.0" ]
[ "-1.0e2" parse-number number>string ]
unit-test

[ "0.01" ]
[ "1.0e-2" parse-number number>string ]
unit-test

[ "-0.01" ]
[ "-1.0e-2" parse-number number>string ]
unit-test

[ f ]
[ "-1e-2e4" parse-number ]
unit-test

[ "3.14" ]
[ "3.14" parse-number number>string ]
unit-test

[ f ]
[ "." parse-number ]
unit-test

[ f ]
[ ".e" parse-number ]
unit-test

[ "101.0" ]
[ "1.01e2" parse-number number>string ]
unit-test

[ "-101.0" ]
[ "-1.01e2" parse-number number>string ]
unit-test

[ "1.01" ]
[ "101.0e-2" parse-number number>string ]
unit-test

[ "-1.01" ]
[ "-101.0e-2" parse-number number>string ]
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

[ 5.0 ]
[ "10.0/2" parse-number ]
unit-test

[ f ]
[ "1e1/2" parse-number ]
unit-test

[ f ]
[ "e/2" parse-number ]
unit-test

[ "33/100" ]
[ "66/200" parse-number number>string ]
unit-test

[ "12" bin> ] unit-test-fails
[ "fdsf" bin> ] unit-test-fails
[ 3 ] [ "11" bin> ] unit-test

[ t ] [
    { "1.0/0.0" "-1.0/0.0" "0.0/0.0" }
    [ dup string>number number>string = ] all?
] unit-test

[ t ] [
    { 1.0/0.0 -1.0/0.0 0.0/0.0 }
    [ dup number>string string>number = ] all?
] unit-test
