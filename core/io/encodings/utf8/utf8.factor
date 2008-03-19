! Copyright (C) 2006, 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel sequences sbufs vectors growable io continuations
namespaces io.encodings combinators strings ;
IN: io.encodings.utf8

! Decoding UTF-8

TUPLE: utf8 ;

<PRIVATE 

: starts-2? ( char -- ? )
    dup [ -6 shift BIN: 10 number= ] when ;

: append-nums ( stream byte -- stream char )
    over stream-read1 dup starts-2?
    [ swap 6 shift swap BIN: 111111 bitand bitor ]
    [ 2drop replacement-char ] if ;

: double ( stream byte -- stream char )
    BIN: 11111 bitand append-nums ;

: triple ( stream byte -- stream char )
    BIN: 1111 bitand append-nums append-nums ;

: quad ( stream byte -- stream char )
    BIN: 111 bitand append-nums append-nums append-nums ;

: begin-utf8 ( stream byte -- stream char )
    {
        { [ dup -7 shift zero? ] [ ] }
        { [ dup -5 shift BIN: 110 number= ] [ double ] }
        { [ dup -4 shift BIN: 1110 number= ] [ triple ] }
        { [ dup -3 shift BIN: 11110 number= ] [ quad ] }
        { [ t ] [ drop replacement-char ] }
    } cond ;

: decode-utf8 ( stream -- char/f )
    dup stream-read1 dup [ begin-utf8 ] when nip ;

M: utf8 decode-char
    drop decode-utf8 ;

! Encoding UTF-8

: encoded ( stream char -- )
    BIN: 111111 bitand BIN: 10000000 bitor swap stream-write1 ;

: char>utf8 ( stream char -- )
    {
        { [ dup -7 shift zero? ] [ swap stream-write1 ] }
        { [ dup -11 shift zero? ] [
            2dup -6 shift BIN: 11000000 bitor swap stream-write1
            encoded
        ] }
        { [ dup -16 shift zero? ] [
            2dup -12 shift BIN: 11100000 bitor swap stream-write1
            2dup -6 shift encoded
            encoded
        ] }
        { [ t ] [
            2dup -18 shift BIN: 11110000 bitor swap stream-write1
            2dup -12 shift encoded
            2dup -6 shift encoded
            encoded
        ] }
    } cond ;

M: utf8 encode-char
    drop swap char>utf8 ;

PRIVATE>
