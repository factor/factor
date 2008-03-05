! Copyright (C) 2006, 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors growable io continuations
namespaces io.encodings combinators strings ;
IN: io.encodings.utf8

! Decoding UTF-8

TUPLE: utf8 ch state ;

SYMBOL: double
SYMBOL: triple
SYMBOL: triple2
SYMBOL: quad
SYMBOL: quad2
SYMBOL: quad3

: starts-2? ( char -- ? )
    -6 shift BIN: 10 number= ;

: append-nums ( buf bottom top state-out -- buf num state )
    >r over starts-2?
    [ 6 shift swap BIN: 111111 bitand bitor r> ]
    [ r> 3drop push-replacement ] if ;

: begin-utf8 ( buf byte -- buf ch state )
    {
        { [ dup -7 shift zero? ] [ push-decoded ] }
        { [ dup -5 shift BIN: 110 number= ] [ BIN: 11111 bitand double ] }
        { [ dup -4 shift BIN: 1110 number= ] [ BIN: 1111 bitand triple ] }
        { [ dup -3 shift BIN: 11110 number= ] [ BIN: 111 bitand quad ] }
        { [ t ] [ drop push-replacement ] }
    } cond ;

: end-multibyte ( buf byte ch -- buf ch state )
    f append-nums [ push-decoded ] unless* ;

: decode-utf8-step ( buf byte ch state -- buf ch state )
    {
        { begin [ drop begin-utf8 ] }
        { double [ end-multibyte ] }
        { triple [ triple2 append-nums ] }
        { triple2 [ end-multibyte ] }
        { quad [ quad2 append-nums ] }
        { quad2 [ quad3 append-nums ] }
        { quad3 [ end-multibyte ] }
    } case ;

: unpack-state ( encoding -- ch state )
    { utf8-ch utf8-state } get-slots ;

: pack-state ( ch state encoding -- )
    { set-utf8-ch set-utf8-state } set-slots ;

M: utf8 decode-step ( buf char encoding -- )
    [ unpack-state decode-utf8-step ] keep pack-state drop ;

M: utf8 init-decoder nip begin over set-utf8-state ;

! Encoding UTF-8

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

M: utf8 encode-string drop encode-utf8 ;
