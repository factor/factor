! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors base64.private byte-arrays combinators endian
grouping io io.encodings.binary io.encodings.string
io.encodings.utf8 io.files io.streams.byte-array kernel
kernel.private literals make math math.bitwise sequences
splitting.monotonic ;

IN: binhex

TUPLE: binhex name type auth flags data resource ;

<PRIVATE

: rel90, ( ch -- )
    [ , ] [ 0x90 = [ 0x00 , ] when ] bi ;

: rel90% ( slice -- )
    [ first ] [ length 255 /mod ] bi
    [ [ dup rel90, 0x90 , 0xff , ] times rel90, ]
    [ dup 1 > [ 0x90 , , ] [ drop ] if ] bi* ;

: rle90-encode ( bytes -- bytes' )
    [ [ = ] monotonic-split-slice [ rel90% ] each ] B{ } make ;

: rle90-decode ( bytes -- bytes' )
    binary [
        [
            0 [
                read1 [
                    dup 0x90 = [
                        drop read1 dup 0x00 =
                        [ 2drop 0x90 dup , ]
                        [ 1 - over <repetition> % ] if
                    ] [
                        nip dup [ , ] when*
                    ] if
                ] keep
            ] loop drop
        ] B{ } make
    ] with-byte-reader ;

<<
CONSTANT: alphabet $[
    "!\"#$%&'()*+,-012345689@ABCDEFGHIJKLMNPQRSTUVXYZ[`abcdefhijklmpqr"
    >byte-array
]
>>

ERROR: malformed-hqx ;

: ch>hqx ( ch -- ch )
    alphabet nth ; inline

: hqx>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-hqx ] unless* { fixnum } declare ; inline

: hqx-decode ( chars -- bytes )
    [
        [ 0 0 ] dip [
            dup "\r\n\t\s" member? [ drop ] [
                hqx>ch swap {
                    { 0 [ nip 6 ] }
                    { 2 [ [ 6 shift ] dip + , 0 0 ] }
                    { 4 [ [ 4 shift ] dip [ -2 shift + , ] [ 2 bits ] bi 2 ] }
                    { 6 [ [ 2 shift ] dip [ -4 shift + , ] [ 4 bits ] bi 4 ] }
                } case
            ] if
        ] each 2drop
    ] B{ } make ;

: hqx-encode ( bytes -- chars )
    [
        [ 0 0 ] dip [
            swap {
                { 0 [ nip [ -2 shift ch>hqx , ] [ 2 bits ] bi 2 ] }
                { 2 [ [ 4 shift ] dip [ -4 shift + ch>hqx , ] [ 4 bits ] bi 4 ] }
                { 4 [ [ 2 shift ] dip [ -6 shift + ch>hqx , ] [ 6 bits ] bi 6 ] }
                { 6 [ [ ch>hqx , ] dip [ -2 shift ch>hqx , ] [ 2 bits ] bi 2 ] }
            } case
        ] each 6 swap - shift ch>hqx ,
    ] B{ } make ;

: crc16-binhex ( bytes -- n )
    0 [| b |
        8 <iota> [| i |
            dup 15 bit?
            [
                2 * 0xffff bitand
                b 7 i - bit? [ 1 + ] when
            ]
            [ [ 0x1021 bitxor ] when ] bi*
        ] each
    ] reduce
    16 [
        dup 15 bit?
        [ 2 * 0xffff bitand ]
        [ [ 0x1021 bitxor ] when ] bi*
    ] times ;

: check-crc ( bytes -- bytes )
    dup crc16-binhex 2 read be> assert= ;

: skip-return ( -- ch )
    read1 [ dup "\r\n\t\s" member? ] [ drop read1 ] while ;

:: read-header ( -- name type auth flags #data #resource )
    read1 :> n
    n 19 + read n prefix check-crc :> header
    1 dup n + header subseq utf8 decode
    n 2 + dup 4 + header subseq be>
    n 6 + dup 4 + header subseq be>
    n 10 + dup 2 + header subseq be>
    n 12 + dup 4 + header subseq be>
    n 16 + dup 4 + header subseq be> ;

PRIVATE>

: read-binhex ( -- binhex )
    "\r\n" read-until drop
    "(This file must be converted " head? t assert=
    skip-return CHAR: : assert=
    ":" read-until CHAR: : assert=
    hqx-decode rle90-decode
    binary [
        read-header [ read check-crc ] bi@ binhex boa
    ] with-byte-reader ;

: file>binhex ( path -- binhex )
    binary [ read-binhex ] with-file-reader ;

<PRIVATE

CONSTANT: begin $[
    "(This file must be converted with BinHex 4.0)" >byte-array
]

: write-with-crc ( bytes -- )
    [ write ] [ crc16-binhex 2 >be write ] bi ;

: write-header ( binhex -- )
    binary [
        {
            [ name>> utf8 encode [ length write1 ] [ write ] bi 0 write1 ]
            [ type>> 4 >be write ]
            [ auth>> 4 >be write ]
            [ flags>> 2 >be write ]
            [ data>> length 4 >be write ]
            [ resource>> length 4 >be write ]
        } cleave
    ] with-byte-writer write-with-crc ;

PRIVATE>

: write-binhex ( binhex -- )
    begin write
    CHAR: \r write1
    CHAR: \r write1
    CHAR: : write1
    binary [
        [ write-header ] [ data>> ] [ resource>> ] tri
        [ write-with-crc ] bi@
    ] with-byte-writer
    rle90-encode hqx-encode
    64 group [ CHAR: \r write1 ] [ write ] interleave
    CHAR: : write1
    CHAR: \r write1 ;

: binhex>file ( binhex path -- )
    binary [ write-binhex ] with-file-writer ;
