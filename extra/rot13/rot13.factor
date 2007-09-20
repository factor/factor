! Copyright (C) 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences strings io combinators ;
IN: rot13

: rotate ( ch base -- ch ) tuck - 13 + 26 mod + ;

: rot-letter ( ch -- ch )
    {
        { [ dup letter? ] [ CHAR: a rotate ] }
        { [ dup LETTER? ] [ CHAR: A rotate ] }
        { [ t ] [ ] }
    } cond ;

: rot13 ( string -- string ) [ rot-letter ] map ;

: rot13-demo ( -- )
    "Please enter a string:" print flush
    readln [
        "Your string: " write dup print
        "Rot13:       " write rot13 print
    ] when* ;

MAIN: rot13-demo
