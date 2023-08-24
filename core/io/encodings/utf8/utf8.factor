! Copyright (C) 2006, 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings
io.encodings.private kernel math math.order sequences strings ;
IN: io.encodings.utf8

! Decoding UTF-8

SINGLETON: utf8

<PRIVATE

: starts-2? ( char -- ? )
    dup [ -6 shift 0b10 number= ] when ; inline

: append-nums ( stream byte -- stream char )
    over stream-read1 dup starts-2?
    [ [ 6 shift ] dip 0b111111 bitand bitor ]
    [ 2drop replacement-char ] if ; inline

: minimum-code-point ( char minimum -- char )
    over > [ drop replacement-char ] when ; inline

: maximum-code-point ( char maximum -- char )
    over < [ drop replacement-char ] when ; inline

: double ( stream byte -- stream char )
    0b11111 bitand append-nums
    0x80 minimum-code-point ; inline

: triple ( stream byte -- stream char )
    0b1111 bitand append-nums append-nums
    0x800 minimum-code-point ; inline

: quadruple ( stream byte -- stream char )
    0b111 bitand append-nums append-nums append-nums
    0x10000 minimum-code-point
    0x10FFFF maximum-code-point ; inline

: begin-utf8 ( stream byte -- stream char )
    dup 127 > [
        {
            { [ dup -5 shift 0b110 = ] [ double ] }
            { [ dup -4 shift 0b1110 = ] [ triple ] }
            { [ dup -3 shift 0b11110 = ] [ quadruple ] }
            [ drop replacement-char ]
        } cond
    ] when ; inline

: decode-utf8 ( stream -- char/f )
    dup stream-read1 dup [ begin-utf8 ] when nip ; inline

M: utf8 decode-char
    drop decode-utf8 ; inline

M: utf8 decode-until (decode-until) ;

! Encoding UTF-8

: encoded ( stream char -- )
    0b111111 bitand 0b10000000 bitor swap stream-write1 ; inline

: char>utf8 ( char stream -- )
    over 127 <= [ stream-write1 ] [
        swap {
            { [ dup -11 shift zero? ] [
                2dup -6 shift 0b11000000 bitor swap stream-write1
                encoded
            ] }
            { [ dup -16 shift zero? ] [
                2dup -12 shift 0b11100000 bitor swap stream-write1
                2dup -6 shift encoded
                encoded
            ] }
            [
                2dup -18 shift 0b11110000 bitor swap stream-write1
                2dup -12 shift encoded
                2dup -6 shift encoded
                encoded
            ]
        } cond
    ] if ; inline

M: utf8 encode-char
    drop char>utf8 ;

GENERIC#: encode-string-utf8 1 ( string stream -- )

M: object encode-string-utf8
    [ char>utf8 ] curry each ; inline

M: string encode-string-utf8
    over aux>>
    [ call-next-method ]
    [ [ string>byte-array-fast ] dip stream-write ] if ; inline

M: utf8 encode-string drop encode-string-utf8 ;

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
