! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test constructors calendar kernel accessors
combinators.short-circuit ;
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