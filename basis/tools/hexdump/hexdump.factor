! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors ascii byte-arrays byte-vectors combinators
command-line destructors formatting fry io io.encodings
io.encodings.binary io.files io.streams.string kernel literals
locals math math.parser namespaces sequences sequences.private
strings typed ;

IN: tools.hexdump

<PRIVATE

: write-header ( len -- )
    dup "Length: %d, %xh\n" printf ;

CONSTANT: line# "00000000h: "

: inc-line# ( -- )
    7 [ CHAR: 0 = over 0 > and ] [
        1 - dup line# [
            {
                { CHAR: 9 [ CHAR: a ] }
                { CHAR: f [ CHAR: 0 ] }
                [ 1 + ]
            } case dup
        ] change-nth-unsafe
    ] do while drop ;

: reset-line# ( -- )
    7 [ CHAR: 0 swap line# set-nth ] each-integer ;

CONSTANT: hex-digits $[
    256 <iota> [ >hex 2 CHAR: 0 pad-head " " append ] map
]

: all-bytes ( bytes -- from to bytes )
    [ 0 swap length ] keep ; inline

: each-byte ( from to bytes quot: ( elt -- ) -- )
    '[ _ nth-unsafe @ ] (each-integer) ; inline

: write-bytes ( from to bytes stream -- )
    '[ hex-digits nth-unsafe _ stream-write ] each-byte ; inline

: write-space ( from to bytes stream -- )
    [ drop - 16 + ] dip '[
        3 * CHAR: \s <string> _ stream-write
    ] unless-zero ; inline

: write-ascii ( from to bytes stream -- )
    '[ [ printable? ] keep CHAR: . ? _ stream-write1 ] each-byte ; inline

TYPED: write-hex-line ( from: fixnum to: fixnum bytes: byte-array -- )
    line# write inc-line# output-stream get {
        [ write-bytes ]
        [ write-space ]
        [ write-ascii ]
    } 4cleave nl ;

:: hexdump-bytes ( from to bytes -- )
    reset-line#
    to from - :> len
    len write-header
    len 16 /mod
    [ [ 16 * dup 16 + bytes write-hex-line ] each-integer ]
    [ [ len swap - len bytes write-hex-line ] unless-zero ] bi* ;

: hexdump-stream ( stream -- )
    reset-line#
    [ stream-length write-header ]
    [ [ all-bytes write-hex-line ] 16 (each-stream-block) ] bi ;

PRIVATE>

GENERIC: hexdump. ( byte-array -- )

M: byte-array hexdump. all-bytes hexdump-bytes ;

M: byte-vector hexdump. all-bytes underlying>> hexdump-bytes ;

: hexdump ( byte-array -- str )
    [ hexdump. ] with-string-writer ;

: hexdump-file ( path -- )
    binary <file-reader> [ hexdump-stream ] with-disposal ;

: hexdump-main ( -- )
    command-line get [
        input-stream get dup decoder? [ stream>> ] when
        hexdump-stream
    ] [
        [ hexdump-file ] each
    ] if-empty ;

MAIN: hexdump-main
