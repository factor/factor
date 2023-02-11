! Copyright (C) 2022 Alex Maestas.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel math sequences ;
IN: unicode.control-pictures

<PRIVATE

: char>control-picture ( char -- char' )
    {
        { [ dup 0x20 < ] [ 0x2400 bitor ] }
        { [ dup 0x7f = ] [ drop 0x2421 ] }
        [ ]
    } cond ;

: char>control-picture* ( char -- char' )
    char>control-picture
    dup 0x20 = [ drop 0x2420 ] when ;

PRIVATE>

: control-pictures ( string -- string )
    [ char>control-picture ] map ;

: control-pictures* ( string -- string )
    [ char>control-picture* ] map ;
