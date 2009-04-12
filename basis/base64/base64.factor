! Copyright (C) 2008 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io io.binary io.encodings.binary
io.streams.byte-array kernel math namespaces
sequences strings io.crlf ;
IN: base64

ERROR: malformed-base64 ;

<PRIVATE

: read1-ignoring ( ignoring -- ch )
    read1 2dup swap member? [ drop read1-ignoring ] [ nip ] if ;

: read-ignoring ( ignoring n -- str )
    [ drop read1-ignoring ] with map harvest
    [ f ] [ >string ] if-empty ;

: ch>base64 ( ch -- ch )
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    nth ; inline

: base64>ch ( ch -- ch )
    {
        f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f
        f f f f f f f f f f 62 f f f 63 52 53 54 55 56 57 58 59 60 61 f f
        f 0 f f f 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
        22 23 24 25 f f f f f f 26 27 28 29 30 31 32 33 34 35 36 37 38 39
        40 41 42 43 44 45 46 47 48 49 50 51
    } nth [ malformed-base64 ] unless* ; inline

SYMBOL: column

: write1-lines ( ch -- )
    write1
    column get [
        1+ [ 76 = [ crlf ] when ]
        [ 76 mod column set ] bi
    ] when* ;

: write-lines ( str -- )
    [ write1-lines ] each ;

: encode3 ( seq -- )
    be> 4 <reversed> [
        -6 * shift HEX: 3f bitand ch>base64 write1-lines
    ] with each ; inline

: encode-pad ( seq n -- )
    [ 3 0 pad-tail binary [ encode3 ] with-byte-writer ]
    [ 1+ ] bi* head-slice 4 CHAR: = pad-tail write-lines ; inline

: decode4 ( seq -- )
    [ 0 [ base64>ch swap 6 shift bitor ] reduce 3 >be ]
    [ [ CHAR: = = ] count ] bi head-slice*
    [ write1 ] each ; inline

PRIVATE>

: encode-base64 ( -- )
    3 read dup length {
        { 0 [ drop ] }
        { 3 [ encode3 encode-base64 ] }
        [ encode-pad encode-base64 ]
    } case ;

: encode-base64-lines ( -- )
    0 column [ encode-base64 ] with-variable ;

: decode-base64 ( -- )
    "\n\r" 4 read-ignoring dup length {
        { 0 [ drop ] }
        { 4 [ decode4 decode-base64 ] }
        [ malformed-base64 ]
    } case ;

: >base64 ( seq -- base64 )
    binary [ binary [ encode-base64 ] with-byte-reader ] with-byte-writer ;

: base64> ( base64 -- seq )
    binary [ binary [ decode-base64 ] with-byte-reader ] with-byte-writer ;

: >base64-lines ( seq -- base64 )
    binary [ binary [ encode-base64-lines ] with-byte-reader ] with-byte-writer ;
