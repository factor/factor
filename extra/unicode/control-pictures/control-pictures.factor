! Copyright (C) 2017 Pi.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math sequences ;
IN: unicode.control-pictures

<PRIVATE

: char>control-picture ( char -- char' )
    {
        { [ dup 0x20 < ] [ 0x2400 bitor ] }
        { [ dup 0x7f = ] [ drop 0x2421 ] }
        [ ]
    } cond ;

PRIVATE>

: control-pictures ( string -- string )
    [ char>control-picture ] map ;
