! Copyright (C) 2006, 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors
namespaces io.encodings combinators ;
IN: io.utf8

SYMBOL: double
SYMBOL: triple
SYMBOL: triple2
SYMBOL: quad
SYMBOL: quad2
SYMBOL: quad3

: starts-2? ( char -- ? )
    -6 shift BIN: 10 number= ;

: append-nums ( bottom top -- num )
    over starts-2?
    [ 6 shift swap BIN: 111111 bitand bitor ]
    [ decode-error ] if ;

: begin-utf8 ( buf byte -- buf ch state )
    {
        { [ dup -7 shift zero? ] [ decoded ] }
        { [ dup -5 shift BIN: 110 number= ] [ BIN: 11111 bitand double ] }
        { [ dup -4 shift BIN: 1110 number= ] [ BIN: 1111 bitand triple ] }
        { [ dup -3 shift BIN: 11110 number= ] [ BIN: 111 bitand quad ] }
        { [ t ] [ decode-error ] }
    } cond ;

: end-multibyte ( buf byte ch -- buf ch state )
    append-nums decoded ;

: (decode-utf8) ( buf byte ch state -- buf ch state )
    {
        { begin [ drop begin-utf8 ] }
        { double [ end-multibyte ] }
        { triple [ append-nums triple2 ] }
        { triple2 [ end-multibyte ] }
        { quad [ append-nums quad2 ] }
        { quad2 [ append-nums quad3 ] }
        { quad3 [ end-multibyte ] }
    } case ;

: decode-utf8 ( seq -- str )
    [ -rot (decode-utf8) ] decode ;

: encoded ( char -- )
    BIN: 111111 bitand BIN: 10000000 bitor , ;

: char>utf8 ( char -- )
    {
        { [ dup -7 shift zero? ] [ , ] }
        { [ dup -11 shift zero? ] [
            dup -6 shift BIN: 11000000 bitor ,
            encoded
        ] }
        { [ dup -16 shift zero? ] [
            dup -12 shift BIN: 11100000 bitor ,
            dup -6 shift encoded
            encoded
        ] }
        { [ t ] [
            dup -18 shift BIN: 11110000 bitor ,
            dup -12 shift encoded
            dup -6 shift encoded
            encoded
        ] }
    } cond ;

: encode-utf8 ( str -- seq )
    [ [ char>utf8 ] each ] B{ } make ;
