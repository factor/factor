! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-vectors combinators
combinators.smart compression.huffman fry hashtables io.binary
kernel literals locals math math.bitwise math.order math.ranges
sequences sorting memoize combinators.short-circuit byte-arrays ;
QUALIFIED-WITH: bitstreams bs
IN: compression.inflate

<PRIVATE

ERROR: zlib-unimplemented ;
ERROR: bad-zlib-data ;
ERROR: bad-zlib-header ;

:: check-zlib-header ( data -- )
    16 data bs:peek 2 >le be> 31 mod    ! checksum
    0 assert=
    4 data bs:read 8 assert=            ! compression method: deflate
    4 data bs:read                      ! log2(max length)-8, 32K max
    7 <= [ bad-zlib-header ] unless
    5 data bs:seek                      ! drop check bits
    1 data bs:read 0 assert=            ! dictionary - not allowed in png
    2 data bs:seek                      ! compression level; ignore
    ;

CONSTANT: clen-shuffle { 16 17 18 0 8 7 9 6 10 5 11 4 12 3 13 2 14 1 15 }

: get-table ( values size -- table )
    16 f <array> <enum>
    [ '[ _ push-at ] 2each ] keep
    seq>> rest-slice [ natural-sort ] map ; inline

:: decode-huffman-tables ( bitstream -- tables )
    5 bitstream bs:read 257 +
    5 bitstream bs:read 1 +
    4 bitstream bs:read 4 + clen-shuffle swap head 

    dup length iota [ 3 bitstream bs:read ] replicate
    get-table
    bitstream swap <huffman-decoder>
    [ 2dup + ] dip swap :> k!
    '[
        _ read1-huff2 {
            { [ dup 16 = ] [ 2 bitstream bs:read 3 + 2array ] }
            { [ dup 17 = ] [ 3 bitstream bs:read 3 + 2array ] }
            { [ dup 18 = ] [ 7 bitstream bs:read 11 + 2array ] }
            [ ]
        } cond
        dup array? [ dup second ] [ 1 ] if
        k swap - dup k! 0 >
    ] [ ] produce swap suffix
    { } [
            dup { [ array? ] [ first 16 = ] } 1&& [
                [ unclip-last-slice ]
                [ second 1 + swap <repetition> append ] bi*
            ] [
                suffix
            ] if
    ] reduce
    [ dup array? [ second 0 <repetition> ] [ 1array ] if ] map concat
    nip swap cut 2array
    [ [ length>> iota ] [ ] bi get-table ] map ;

MEMO: static-huffman-tables ( -- obj )
    [
        0 143 [a,b] [ 8 ] replicate
        144 255 [a,b] [ 9 ] replicate append
        256 279 [a,b] [ 7 ] replicate append
        280 287 [a,b] [ 8 ] replicate append
    ] append-outputs
    0 31 [a,b] [ 5 ] replicate 2array
    [ [ length>> [0,b) ] [ ] bi get-table ] map ;

CONSTANT: length-table
    {
        3 4 5 6 7 8 9 10 11 13 15 17 19 23 27 31
        35 43 51 59 67 83 99 115 131 163 195 227 258
    }

CONSTANT: dist-table
    {
        1 2 3 4 5 7 9 13 17 25 33 49
        65 97 129 193 257 385 513 769 1025 1537 2049 3073
        4097 6145 8193 12289 16385 24577
    }

: nth* ( n seq -- elt )
    [ length 1 - swap - ] [ nth ] bi ; inline

:: inflate-lz77 ( seq -- byte-array )
    1000 <byte-vector> :> bytes
    seq [
        dup array?
        [ first2 '[ _ 1 - bytes nth* bytes push ] times ]
        [ bytes push ] if
    ] each
    bytes >byte-array ;

:: inflate-huffman ( bitstream tables -- bytes )
    bitstream tables [ <huffman-decoder> ] with map :> tables
    [
        tables first read1-huff2
        dup 256 > [
            dup 285 = [
                dup 264 > [
                    dup 261 - 4 /i
                    dup 5 > [ bad-zlib-data ] when
                    bitstream bs:read 2array
                ] when
            ] unless

            tables second read1-huff2

            dup 3 > [
                dup 2 - 2 /i dup 13 >
                [ bad-zlib-data ] when
                bitstream bs:read 2array
            ] when 2array
        ] when dup 256 = not
    ] [ ] produce nip
    [
        dup array? [
            first2 [
                dup array? [ first2 ] [ 0 ] if
                [ 257 - length-table nth ] [ + ] bi*
            ] [
                dup array? [ first2 ] [ 0 ] if
                [ dist-table nth ] [ + ] bi*
            ] bi* 2array
        ] when
    ] map ;

:: inflate-raw ( bitstream -- bytes )
    8 bitstream bs:align
    16 bitstream bs:read :> len
    16 bitstream bs:read :> nlen

    ! len + ~len = -1
    len nlen + 16 >signed -1 assert=

    bitstream byte-pos>>
    bitstream byte-pos>> len +
    bitstream bytes>> <slice>
    len 8 * bitstream bs:seek ;

: inflate-dynamic ( bitstream -- array )
    dup decode-huffman-tables inflate-huffman ;

: inflate-static ( bitstream -- array )
    static-huffman-tables inflate-huffman ;

:: inflate-loop ( bitstream -- array )
    [ 1 bitstream bs:read 0 = ] [
        bitstream
        2 bitstream bs:read
        {
            { 0 [ inflate-raw ] }
            { 1 [ inflate-static ] }
            { 2 [ inflate-dynamic ] }
            { 3 [ bad-zlib-data f ] }
        } case
    ] [ produce ] keep call suffix concat ;

PRIVATE>

: zlib-inflate ( bytes -- bytes )
    bs:<lsb0-bit-reader>
    [ check-zlib-header ] [ inflate-loop ] bi
    inflate-lz77 ;
