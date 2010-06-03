! Copyright (C) 2006, 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays math math.order kernel sequences
sbufs vectors growable io continuations namespaces io.encodings
combinators strings ;
IN: io.encodings.utf8

! Decoding UTF-8

SINGLETON: utf8

<PRIVATE 

: starts-2? ( char -- ? )
    dup [ -6 shift BIN: 10 number= ] when ; inline

: append-nums ( stream byte -- stream char )
    over stream-read1 dup starts-2?
    [ swap 6 shift swap BIN: 111111 bitand bitor ]
    [ 2drop replacement-char ] if ; inline

: double ( stream byte -- stream char )
    BIN: 11111 bitand append-nums ; inline

: triple ( stream byte -- stream char )
    BIN: 1111 bitand append-nums append-nums ; inline

: quadruple ( stream byte -- stream char )
    BIN: 111 bitand append-nums append-nums append-nums ; inline

: begin-utf8 ( stream byte -- stream char )
    {
        { [ dup -7 shift zero? ] [ ] }
        { [ dup -5 shift BIN: 110 = ] [ double ] }
        { [ dup -4 shift BIN: 1110 = ] [ triple ] }
        { [ dup -3 shift BIN: 11110 = ] [ quadruple ] }
        [ drop replacement-char ]
    } cond ; inline

: decode-utf8 ( stream -- char/f )
    dup stream-read1 dup [ begin-utf8 ] when nip ; inline

M: utf8 decode-char
    drop decode-utf8 ; inline

! Encoding UTF-8

: encoded ( stream char -- )
    BIN: 111111 bitand BIN: 10000000 bitor swap stream-write1 ; inline

: char>utf8 ( char stream -- )
    swap {
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
        [
            2dup -18 shift BIN: 11110000 bitor swap stream-write1
            2dup -12 shift encoded
            2dup -6 shift encoded
            encoded
        ]
    } cond ; inline

M: utf8 encode-char
    drop char>utf8 ;

M: utf8 encode-string
    drop
    over aux>>
    [ [ char>utf8 ] curry each ]
    [ [ >byte-array ] dip stream-write ] if ;

PRIVATE>

: code-point-length ( n -- x )
    [ 1 ] [
        log2 {
            { [ dup 0 6 between? ] [ 1 ] }
            { [ dup 7 10 between? ] [ 2 ] }
            { [ dup 11 15 between? ] [ 3 ] }
            { [ dup 16 20 between? ] [ 4 ] }
        } cond nip
    ] if-zero ;

: code-point-offsets ( string -- indices )
    0 [ code-point-length + ] accumulate swap suffix ;

: utf8-index> ( n string -- n' )
    code-point-offsets [ <= ] with find drop ;

: >utf8-index ( n string -- n' )
    code-point-offsets nth ;
