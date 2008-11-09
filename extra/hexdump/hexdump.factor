! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io io.streams.string kernel math math.parser
namespaces sequences splitting grouping strings ascii ;
IN: hexdump

<PRIVATE

: write-header ( len -- )
    "Length: " write
    [ number>string write ", " write ]
    [ >hex write "h" write nl ] bi ;

: write-offset ( lineno -- )
    16 * >hex 8 CHAR: 0 pad-left write "h: " write ;

: >hex-digit ( digit -- str )
    >hex 2 CHAR: 0 pad-left " " append ;

: >hex-digits ( bytes -- str )
    [ >hex-digit ] { } map-as concat 48 CHAR: \s pad-right ;

: >ascii ( bytes -- str )
    [ [ printable? ] keep CHAR: . ? ] map ;

: write-hex-line ( str lineno -- )
    write-offset [ >hex-digits write ] [ >ascii write ] bi nl ;

PRIVATE>

: hexdump. ( seq -- )
    [ length write-header ]
    [ 16 <sliced-groups> [ write-hex-line ] each-index ] bi ;

: hexdump ( seq -- str )
    [ hexdump. ] with-string-writer ;
