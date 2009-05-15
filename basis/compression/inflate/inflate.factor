! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays
byte-vectors combinators constructors fry grouping hashtables
compression.huffman images io.binary kernel locals
math math.bitwise math.order math.ranges multiline sequences
sorting ;
IN: compression.inflate

QUALIFIED-WITH: bitstreams bs

<PRIVATE

: enum>seq ( assoc -- seq )
    dup keys [ ] [ max ] map-reduce 1 + f <array>
    [ '[ swap _ set-nth ] assoc-each ] keep ;

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
    1 data bs:read 0 assert=            ! dictionnary - not allowed in png
    2 data bs:seek                      ! compression level; ignore
    ;

:: default-table ( -- table )
    0 <hashtable> :> table
    0 143 [a,b] 280 287 [a,b] append 8 table set-at
    144 255 [a,b] >array 9 table set-at
    256 279 [a,b] >array 7 table set-at 
    table enum>seq 1 tail ;

CONSTANT: clen-shuffle { 16 17 18 0 8 7 9 6 10 5 11 4 12 3 13 2 14 1 15 }

: get-table ( values size -- table ) 
    16 f <array> clone <enum> 
    [ '[ _ push-at ] 2each ] keep seq>> 1 tail [ natural-sort ] map ;

:: decode-huffman-tables ( bitstream -- tables )
    5 bitstream bs:read 257 +
    5 bitstream bs:read 1 +
    4 bitstream bs:read 4 +
    clen-shuffle swap head
    dup [ drop 3 bitstream bs:read ] map
    get-table
    bitstream swap <huffman-decoder> 
    [ 2dup + ] dip swap :> k!
    '[
        _ read1-huff2
        {
            { [ dup 16 = ] [ 2 bitstream bs:read 3 + 2array ] }
            { [ dup 17 = ] [ 3 bitstream bs:read 3 + 2array ] }
            { [ dup 18 = ] [ 7 bitstream bs:read 11 + 2array ] }
            [ ]
        } cond
        dup array? [ dup second ] [ 1 ] if
        k swap - dup k! 0 >
    ] 
    [ ] produce swap suffix
    { } [ dup array? [ dup first 16 = ] [ f ] if [ [ unclip-last ] [ second 1+ swap <repetition> append ] bi* ] [ suffix ] if ] reduce
    [ dup array? [ second 0 <repetition> ] [ 1array ] if ] map concat
    nip swap cut 2array [ [ length>> [0,b) ] [ ] bi get-table ] map ;
    
CONSTANT: length-table
    {
        3 4 5 6 7 8 9 10
        11 13 15 17
        19 23 27 31
        35 43 51 59
        67 83 99 115
        131 163 195 227
    }

CONSTANT: dist-table
    { 1 2 3 4 
      5 7 9 13 
      17 25 33 49
      65 97 129 193
      257 385 513 769
      1025 1537 2049 3073
      4097 6145 8193 12289
      16385 24577 }

: nth* ( n seq -- elt )
    [ length 1- swap - ] [ nth ] bi ;

:: inflate-lz77 ( seq -- bytes )
    1000 <byte-vector> :> bytes
    seq
    [
        dup array?
        [ first2 '[ _ 1- bytes nth* bytes push ] times ]
        [ bytes push ] if
    ] each 
    bytes ;

:: inflate-dynamic ( bitstream -- bytes )
    bitstream decode-huffman-tables
    bitstream '[ _ swap <huffman-decoder> ] map :> tables
    [
        tables first read1-huff2
        dup 256 >
        [
            dup 285 = 
            [ ]
            [ 
                dup 264 > 
                [ 
                    dup 261 - 4 /i dup 5 > 
                    [ bad-zlib-data ] when 
                    bitstream bs:read 2array 
                ]
                when 
            ] if
            ! 5 bitstream read-bits ! distance
            tables second read1-huff2
            dup 3 > 
            [ 
                dup 2 - 2 /i dup 13 >
                [ bad-zlib-data ] when
                bitstream bs:read 2array
            ] 
            when
            2array
        ]
        when
        dup 256 = not
    ]
    [ ] produce nip
    [
        dup array? [
            first2
            [  
                dup array? [ first2 ] [ 0 ] if
                [ 257 - length-table nth ] [ + ] bi*
            ] 
            [
                dup array? [ first2 ] [ 0 ] if
                [ dist-table nth ] [ + ] bi*
            ] bi*
            2array
        ] when
    ] map ;
    
: inflate-raw ( bitstream -- bytes ) zlib-unimplemented ;
: inflate-static ( bitstream -- bytes ) zlib-unimplemented ;

:: inflate-loop ( bitstream -- bytes )
    [ 1 bitstream bs:read 0 = ]
    [
        bitstream
        2 bitstream bs:read ! B
        { 
            { 0 [ inflate-raw ] }
            { 1 [ inflate-static ] }
            { 2 [ inflate-dynamic ] }
            { 3 [ bad-zlib-data f ] }
        }
        case
    ]
    [ produce ] keep call suffix concat ;
    
  !  [ produce ] keep dip swap suffix

:: paeth ( a b c -- p ) 
    a b + c - { a b c } [ [ - abs ] keep 2array ] with map 
    sort-keys first second ;
    
:: png-unfilter-line ( prev curr filter -- curr' )
    prev :> c
    prev 3 tail-slice :> b
    curr :> a
    curr 3 tail-slice :> x
    x length [0,b)
    filter
    {
        { 0 [ drop ] }
        { 1 [ [| n | n x nth n a nth + 256 wrap n x set-nth ] each ] }
        { 2 [ [| n | n x nth n b nth + 256 wrap n x set-nth ] each ] }
        { 3 [ [| n | n x nth n a nth n b nth + 2/ + 256 wrap n x set-nth ] each ] }
        { 4 [ [| n | n x nth n a nth n b nth n c nth paeth + 256 wrap n x set-nth ] each ] }
        
    } case 
    curr 3 tail ;

PRIVATE>

! for debug -- shows residual values
: reverse-png-filter' ( lines -- filtered )
    [ first ] [ 1 tail ] [ map ] bi-curry@ bi nip
    concat [ 128 + 256 wrap ] map ;
    
: reverse-png-filter ( lines -- filtered )
    dup first [ 0 ] replicate prefix
    [ { 0 0 } prepend  ] map
    2 clump [ first2 dup [ third ] [ 0 2 rot set-nth ] bi png-unfilter-line ] map concat ;

: zlib-inflate ( bytes -- bytes )
    bs:<lsb0-bit-reader>
    [ check-zlib-header ]
    [ inflate-loop ] bi
    inflate-lz77 ;
