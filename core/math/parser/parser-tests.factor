USING: kernel math math.parser sequences tools.test ;
IN: temporary

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

[ "-1.0e-12" ]
[ "-1.0e-12" string>number number>string ]
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

[ 5 ]
[ "10/2" string>number ]
unit-test

[ -5 ]
[ "-10/2" string>number ]
unit-test

[ -5 ]
[ "10/-2" string>number ]
unit-test

[ 5 ]
[ "-10/-2" string>number ]
unit-test

[ 5.0 ]
[ "10.0/2" string>number ]
unit-test

[ f ]
[ "1e1/2" string>number ]
unit-test

[ f ]
[ "e/2" string>number ]
unit-test

[ "33/100" ]
[ "66/200" string>number number>string ]
unit-test

[ f ] [ "12" bin> ] unit-test
[ f ] [ "fdsf" bin> ] unit-test
[ 3 ] [ "11" bin> ] unit-test

[ f ] [ "\0." string>number ] unit-test

! [ t ] [
!     { "1.0/0.0" "-1.0/0.0" "0.0/0.0" }
!     [ dup string>number number>string = ] all?
! ] unit-test
! 
! [ t ] [
!     { 1.0/0.0 -1.0/0.0 0.0/0.0 }
!     [ dup number>string string>number = ] all?
! ] unit-test

[ 1 1 >base ] unit-test-fails
[ 1 0 >base ] unit-test-fails
[ 1 -1 >base ] unit-test-fails
