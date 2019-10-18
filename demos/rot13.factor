! Copyright (C) 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: rot13
USING: kernel math sequences strings ;

: rotate ( ch base -- ch ) tuck - 13 + 26 mod + ;

: rot-letter ( ch -- ch )
    {
        { [ dup letter? ] [ CHAR: a rotate ] }
        { [ dup LETTER? ] [ CHAR: A rotate ] }
        { [ t ] [ ] }
    } cond ;

: rot13 ( string -- string ) [ rot-letter ] map ;

PROVIDE: demos/rot13 ;
