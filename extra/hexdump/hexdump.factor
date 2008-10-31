! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io io.streams.string kernel math math.parser
namespaces prettyprint sequences splitting grouping strings
ascii ;
IN: hexdump

<PRIVATE

: write-header ( len -- )
    "Length: " write
    [ unparse write ", " write ]
    [ >hex write "h" write nl ] bi ;

: write-offset ( lineno -- )
    16 * >hex 8 CHAR: 0 pad-left write "h: " write ;

: write-hex-digit ( digit -- )
    >hex 2 CHAR: 0 pad-left write ;

: write-hex-line ( str n -- )
    write-offset
    dup [ write-hex-digit bl ] each
    16 over length - 3 * CHAR: \s <string> write
    [ dup printable? [ drop CHAR: . ] unless write1 ] each
    nl ;

PRIVATE>

: hexdump ( seq -- str )
    [
        [ length write-header ]
        [ 16 <sliced-groups> [ write-hex-line ] each-index ] bi
    ] with-string-writer ;

: hexdump. ( seq -- ) hexdump write ;
