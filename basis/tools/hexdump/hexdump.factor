! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii byte-arrays byte-vectors grouping io
io.encodings.binary io.files io.streams.string kernel math
math.parser namespaces sequences splitting strings ;
IN: tools.hexdump

<PRIVATE

: write-header ( len -- )
    "Length: " write
    [ number>string write ", " write ]
    [ >hex write "h" write nl ] bi ;

: write-offset ( lineno -- )
    16 * >hex 8 CHAR: 0 pad-head write "h: " write ;

: >hex-digit ( digit -- str )
    >hex 2 CHAR: 0 pad-head ;

: >hex-digits ( bytes -- str )
    [ >hex-digit " " append ] { } map-as concat
    48 CHAR: \s pad-tail ;

: >ascii ( bytes -- str )
    [ [ printable? ] keep CHAR: . ? ] "" map-as ;

: write-hex-line ( bytes lineno -- )
    write-offset [ >hex-digits write ] [ >ascii write ] bi nl ;

: hexdump-bytes ( bytes -- )
    [ length write-header ]
    [ 16 <groups> [ write-hex-line ] each-index ] bi ;

PRIVATE>

GENERIC: hexdump. ( byte-array -- )

M: byte-array hexdump. hexdump-bytes ;

M: byte-vector hexdump. hexdump-bytes ;

: hexdump ( byte-array -- str )
    [ hexdump. ] with-string-writer ;

: hexdump-file ( path -- )
    binary file-contents hexdump. ;
