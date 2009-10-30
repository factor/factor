! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: infix infix.private kernel locals math math.functions
tools.test ;
IN: infix.tests

[ 0 ] [ [infix 0 infix] ] unit-test
[ 0.5 ] [ [infix 3.0/6 infix] ] unit-test
[ 1+2/3 ] [ [infix 5/3 infix] ] unit-test
[ 3 ] [ [infix 2*7%3+1 infix] ] unit-test
[ 1 ] [ [infix 2-
     1
     -5*
     0 infix] ] unit-test

[ 0.0 ] [ [infix sin(0) infix] ] unit-test
[ 10 ] [ [infix lcm(2,5) infix] ] unit-test
[ 1.0 ] [ [infix +cos(-0*+3) infix] ] unit-test

[ f ] [ 2 \ gcd check-word ] unit-test ! multiple return values
[ f ] [ 1 \ drop check-word ] unit-test ! no return value
[ f ] [ 1 \ lcm check-word ] unit-test ! takes 2 args

: qux ( -- x ) 2 ;
[ t ] [ 0 \ qux check-word ] unit-test
[ 8 ] [ [infix qux()*3+2 infix] ] unit-test
: foobar ( x -- y ) 1 + ;
[ t ] [ 1 \ foobar check-word ] unit-test
[ 4 ] [ [infix foobar(3*5%12) infix] ] unit-test
: stupid_function ( x x x x x -- y ) + + + + ;
[ t ] [ 5 \ stupid_function check-word ] unit-test
[ 10 ] [ [infix stupid_function (0, 1, 2, 3, 4) infix] ] unit-test

[ -1 ] [ [let 1 :> a [infix -a infix] ] ] unit-test
