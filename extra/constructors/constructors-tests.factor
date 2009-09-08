! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test constructors calendar kernel accessors
combinators.short-circuit initializers math ;
IN: constructors.tests

TUPLE: stock-spread stock spread timestamp ;

CONSTRUCTOR: stock-spread ( stock spread -- stock-spread )
   now >>timestamp ;

SYMBOL: AAPL

[ t ] [
    AAPL 1234 <stock-spread>
    {
        [ stock>> AAPL eq? ]
        [ spread>> 1234 = ]
        [ timestamp>> timestamp? ]
    } 1&&
] unit-test

TUPLE: ct1 a ;
TUPLE: ct2 < ct1 b ;
TUPLE: ct3 < ct2 c ;
TUPLE: ct4 < ct3 d ;

CONSTRUCTOR: ct1 ( a -- obj )
    [ 1 + ] change-a ;

CONSTRUCTOR: ct2 ( a b -- obj )
    [ 1 + ] change-a ;

CONSTRUCTOR: ct3 ( a b c -- obj )
    [ 1 + ] change-a ;

CONSTRUCTOR: ct4 ( a b c d -- obj )
    [ 1 + ] change-a ;

[ 1001 ] [ 1000 <ct1> a>> ] unit-test
[ 2 ] [ 0 0 <ct2> a>> ] unit-test
[ 3 ] [ 0 0 0 <ct3> a>> ] unit-test
[ 4 ] [ 0 0 0 0 <ct4> a>> ] unit-test
