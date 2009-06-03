! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays byte-arrays columns
combinators compression.run-length endian fry grouping images
images.loader io io.binary io.encodings.binary io.files kernel
locals macros math math.bitwise math.functions namespaces
sequences strings summary ;
IN: images.bitmap

: assert-sequence= ( a b -- )
    2dup sequence= [ 2drop ] [ assert ] if ;

: read2 ( -- n ) 2 read le> ;
: read4 ( -- n ) 4 read le> ;
: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

TUPLE: bitmap-image < image ;

! Used to construct the final bitmap-image

TUPLE: loading-bitmap 
size reserved offset header-length width
height planes bit-count compression size-image
x-pels y-pels color-used color-important color-palette color-index
uncompressed-bytes ;

ERROR: bitmap-magic magic ;

M: bitmap-magic summary
    drop "First two bytes of bitmap stream must be 'BM'" ;

<PRIVATE

: 8bit>buffer ( bitmap -- array )
    [ color-palette>> 4 <sliced-groups> [ 3 head-slice ] map ]
    [ color-index>> >array ] bi [ swap nth ] with map concat ;

ERROR: bmp-not-supported n ;

: reverse-lines ( byte-array width -- byte-array )
    <sliced-groups> <reversed> concat ; inline

: bitmap>bytes ( loading-bitmap -- array )
    dup bit-count>>
    {
        { 32 [ color-index>> ] }
        { 24 [ [ color-index>> ] [ width>> 3 * ] bi reverse-lines ] }
        { 8 [ [ 8bit>buffer ] [ width>> 3 * ] bi reverse-lines ] }
        [ bmp-not-supported ]
    } case >byte-array ;

ERROR: unsupported-bitmap-compression compression ;

: uncompress-bitmap ( loading-bitmap -- loading-bitmap' )
    dup compression>> {
        { 0 [ ] }
        { 1 [ [ run-length-uncompress8 ] change-color-index ] }
        { 2 [ "run-length encoding 4" unsupported-bitmap-compression ] }
        { 3 [ "bitfields" unsupported-bitmap-compression ] }
        { 4 [ "jpeg" unsupported-bitmap-compression ] }
        { 5 [ "png" unsupported-bitmap-compression ] }
    } case ;

: loading-bitmap>bytes ( loading-bitmap -- byte-array )
    uncompress-bitmap bitmap>bytes ;

: parse-file-header ( loading-bitmap -- loading-bitmap )
    2 read "BM" assert-sequence=
    read4 >>size
    read4 >>reserved
    read4 >>offset ;

: parse-bitmap-header ( loading-bitmap -- loading-bitmap )
    read4 >>header-length
    read4 >>width
    read4 32 >signed >>height
    read2 >>planes
    read2 >>bit-count
    read4 >>compression
    read4 >>size-image
    read4 >>x-pels
    read4 >>y-pels
    read4 >>color-used
    read4 >>color-important ;

: color-palette-length ( loading-bitmap -- n )
    [ offset>> 14 - ] [ header-length>> ] bi - ;

: color-index-length ( loading-bitmap -- n )
    {
        [ width>> ]
        [ planes>> * ]
        [ bit-count>> * 31 + 32 /i 4 * ]
        [ height>> abs * ]
    } cleave ;

: image-size ( loading-bitmap -- n )
    [ [ width>> ] [ height>> ] bi * ] [ bit-count>> 8 /i ] bi * abs ;

: bitmap-padding ( width -- n )
    3 * 4 mod 4 swap - 4 mod ; inline

:: fixup-color-index ( loading-bitmap -- loading-bitmap )
    loading-bitmap width>> :> width
    width 3 * :> width*3
    loading-bitmap width>> bitmap-padding :> padding
    loading-bitmap [ color-index>> length ] [ height>> abs ] bi /i :> stride
    loading-bitmap
    padding 0 > [
        [
            stride <sliced-groups>
            [ width*3 head-slice ] map concat
        ] change-color-index
    ] when ;

: parse-bitmap ( loading-bitmap -- loading-bitmap )
    dup color-palette-length read >>color-palette
    dup color-index-length read >>color-index
    fixup-color-index ;

: load-bitmap ( path -- loading-bitmap )
    binary [
        loading-bitmap new
        parse-file-header parse-bitmap-header parse-bitmap
    ] with-file-reader ;

ERROR: unknown-component-order bitmap ;

: bitmap>component-order ( loading-bitmap -- object )
    bit-count>> {
        { 32 [ BGRA ] }
        { 24 [ BGR ] }
        { 8 [ BGR ] }
        [ unknown-component-order ]
    } case ;

: loading-bitmap>bitmap-image ( bitmap-image loading-bitmap -- bitmap-image )
    {
        [ loading-bitmap>bytes >>bitmap ]
        [ [ width>> ] [ height>> abs ] bi 2array >>dim ]
        [ height>> 0 < [ t >>upside-down? ] when ]
        [ bitmap>component-order >>component-order ]
    } cleave ;

M: bitmap-image load-image* ( path loading-bitmap -- bitmap )
    swap load-bitmap loading-bitmap>bitmap-image ;

"bmp" bitmap-image register-image-class

PRIVATE>

: bitmap>color-index ( bitmap -- byte-array )
    [
        bitmap>>
        4 <sliced-groups>
        [ 3 head-slice <reversed> ] map
        B{ } join
    ] [
        dim>> first dup bitmap-padding dup 0 > [
            [ 3 * group ] dip '[ _ <byte-array> append ] map
            B{ } join
        ] [
            2drop
        ] if
    ] bi ;

: save-bitmap ( image path -- )
    binary [
        B{ CHAR: B CHAR: M } write
        [
            bitmap>color-index length 14 + 40 + write4
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
                [ bitmap>color-index length write4 ]

                ! x-pels
                [ drop 0 write4 ]

                ! y-pels
                [ drop 0 write4 ]

                ! color-used
                [ drop 0 write4 ]

                ! color-important
                [ drop 0 write4 ]

                ! color-palette
                [
                    [ bitmap>color-index ]
                    [ dim>> first 3 * ]
                    [ dim>> first bitmap-padding + ] tri
                    reverse-lines write
                ]
            } cleave
        ] bi
    ] with-file-writer ;
