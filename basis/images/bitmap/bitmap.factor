! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays byte-arrays columns
combinators fry grouping io io.binary io.encodings.binary io.files
kernel macros math math.bitwise math.functions namespaces sequences
strings images endian summary ;
IN: images.bitmap

TUPLE: loading-bitmap 
magic size reserved offset header-length width
height planes bit-count compression size-image
x-pels y-pels color-used color-important rgb-quads color-index ;

TUPLE: bitmap-image < image ;

! Currently can only handle 24/32bit bitmaps.
! Handles row-reversed bitmaps (their height is negative)

ERROR: bitmap-magic magic ;

M: bitmap-magic summary
    drop "First two bytes of bitmap stream must be 'BM'" ;

<PRIVATE

: array-copy ( bitmap array -- bitmap array' )
    over size-image>> abs memory>byte-array ;

: 8bit>buffer ( bitmap -- array )
    [ rgb-quads>> 4 <sliced-groups> [ 3 head-slice ] map ]
    [ color-index>> >array ] bi [ swap nth ] with map concat ;

ERROR: bmp-not-supported n ;

: raw-bitmap>seq ( bitmap -- array )
    dup bit-count>>
    {
        { 32 [ color-index>> ] }
        { 24 [ color-index>> ] }
        { 16 [ bmp-not-supported ] }
        { 8 [ 8bit>buffer ] }
        { 4 [ bmp-not-supported ] }
        { 2 [ bmp-not-supported ] }
        { 1 [ bmp-not-supported ] }
    } case >byte-array ;

: read2 ( -- n ) 2 read le> ;
: read4 ( -- n ) 4 read le> ;

: parse-file-header ( bitmap -- bitmap )
    2 read dup "BM" sequence= [ bitmap-magic ] unless >>magic
    read4 >>size
    read4 >>reserved
    read4 >>offset ;

: parse-bitmap-header ( bitmap -- bitmap )
    read4 >>header-length
    read4 >>width
    read4 >>height
    read2 >>planes
    read2 >>bit-count
    read4 >>compression
    read4 >>size-image
    read4 >>x-pels
    read4 >>y-pels
    read4 >>color-used
    read4 >>color-important ;

: rgb-quads-length ( loading-bitmap -- n )
    [ offset>> 14 - ] [ header-length>> ] bi - ;

: color-index-length ( loading-bitmap -- n )
    {
        [ width>> ]
        [ planes>> * ]
        [ bit-count>> * 31 + 32 /i 4 * ]
        [ height>> abs * ]
    } cleave ;

: parse-bitmap ( bitmap -- bitmap )
    dup rgb-quads-length read >>rgb-quads
    dup color-index-length read >>color-index ;

: load-bitmap-data ( path loading-bitmap -- loading-bitmap )
    [ binary ] dip '[
        _ parse-file-header parse-bitmap-header parse-bitmap
    ] with-file-reader ;

ERROR: unknown-component-order bitmap ;

: bitmap>component-order ( bitmap -- object )
    bit-count>> {
        { 32 [ BGRA ] }
        { 24 [ BGR ] }
        { 8 [ BGR ] }
        [ unknown-component-order ]
    } case ;

: loading-bitmap>bitmap-image ( loading-bitmap -- bitmap-image )
    [ bitmap-image new ] dip
    {
        [ raw-bitmap>seq >>bitmap ]
        [ [ width>> ] [ height>> ] bi 2array >>dim ]
        [ bitmap>component-order >>component-order ]
    } cleave ;

M: bitmap-image load-image* ( path loading-bitmap -- bitmap )
    drop loading-bitmap new
    load-bitmap-data loading-bitmap>bitmap-image ;

MACRO: (nbits>bitmap) ( bits -- )
    [ -3 shift ] keep '[
        loading-bitmap new
            2over * _ * >>size-image
            swap >>height
            swap >>width
            swap array-copy [ >>bitmap ] [ >>color-index ] bi
            _ >>bit-count
    ] ;

: bgr>bitmap ( array height width -- bitmap )
    24 (nbits>bitmap) ;

: bgra>bitmap ( array height width -- bitmap )
    32 (nbits>bitmap) ;

: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

PRIVATE>

: bitmap>color-index ( bitmap-array -- byte-array )
    4 <sliced-groups> [ 3 head-slice reverse ] map B{ } join ; inline

: save-bitmap ( image path -- )
    binary [
        B{ CHAR: B CHAR: M } write
        [
            bitmap>> bitmap>color-index length 14 + 40 + write4
            0 write4
            54 write4
            40 write4
        ] [
            {
                ! width height
                [ dim>> first2 [ write4 ] bi@ ]

                ! planes
                [ drop 1 write2 ]

                ! bit-count
                [ drop 24 write2 ]

                ! compression
                [ drop 0 write4 ]

                ! size-image
                [ bitmap>> bitmap>color-index length write4 ]

                ! x-pels
                [ drop 0 write4 ]

                ! y-pels
                [ drop 0 write4 ]

                ! color-used
                [ drop 0 write4 ]

                ! color-important
                [ drop 0 write4 ]

                ! rgb-quads
                [ bitmap>> bitmap>color-index write ]
            } cleave
        ] bi
    ] with-file-writer ;
