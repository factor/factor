! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays byte-arrays columns
combinators compression.run-length endian fry grouping images
images.bitmap.loading images.loader io io.binary
io.encodings.8-bit io.encodings.binary io.encodings.string
io.files io.streams.limited kernel locals macros math
math.bitwise math.functions namespaces sequences
specialized-arrays.uint specialized-arrays.ushort strings
summary ;
QUALIFIED-WITH: bitstreams b
IN: images.bitmap

SINGLETON: bitmap-image
"bmp" bitmap-image register-image-class

! endpoints-triple is ciexyzX/Y/Z, 3x fixed-point-2.30 aka 3x uint

: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

<PRIVATE

: os2-color-lookup ( loading-bitmap -- seq )
    [ color-index>> >array ]
    [ color-palette>> 3 <sliced-groups> ] bi
    '[ _ nth ] map concat ;

: os2v2-color-lookup ( loading-bitmap -- seq )
    [ color-index>> >array ]
    [ color-palette>> 3 <sliced-groups> ] bi
    '[ _ nth ] map concat ;

: v3-color-lookup ( loading-bitmap -- seq )
    [ color-index>> >array ]
    [ color-palette>> 4 <sliced-groups> [ 3 head-slice ] map ] bi
    '[ _ nth ] map concat ;

: color-lookup ( loading-bitmap -- seq )
    dup file-header>> header-length>> {
        { 12 [ os2-color-lookup ] }
        { 64 [ os2v2-color-lookup ] }
        { 40 [ v3-color-lookup ] }
        ! { 108 [ v4-color-lookup ] }
        ! { 124 [ v5-color-lookup ] }
    } case ;

ERROR: bmp-not-supported n ;

: uncompress-bitfield ( seq masks -- bytes' )
    '[
        _ [
            [ bitand ] [ bit-count ] [ log2 ] tri - shift
        ] with map
    ] { } map-as B{ } concat-as ;

: bitmap>bytes ( loading-bitmap -- byte-array )
    dup header>> bit-count>>
    {
        { 32 [ color-index>> ] }
        { 24 [ color-index>> ] }
        { 16 [
            [
                ! byte-array>ushort-array
                2 group [ le> ] map
                ! 5 6 5
                ! { HEX: f800 HEX: 7e0 HEX: 1f } uncompress-bitfield
                ! 5 5 5
                { HEX: 7c00 HEX: 3e0 HEX: 1f } uncompress-bitfield
            ] change-color-index
            color-index>>
        ] }
        { 8 [ color-lookup ] }
        { 4 [ B [ 4 b:byte-array-n>seq ] change-color-index color-lookup ] }
        { 1 [ [ 1 b:byte-array-n>seq ] change-color-index color-lookup ] }
        [ bmp-not-supported ]
    } case >byte-array ;

: set-bitfield-widths ( loading-bitmap -- loading-bitmap' )
    dup header>> bit-count>> {
        { 16 [ dup color-palette>> 4 group [ le> ] map ] }
        { 32 [ { HEX: ff0000 HEX: ff00 HEX: ff } ] }
    } case reverse >>bitfields ;

ERROR: unsupported-bitfield-widths n ;

M: unsupported-bitfield-widths summary
    drop "Bitmaps only support bitfield compression in 16/32bit images" ;

: uncompress-bitfield-widths ( loading-bitmap -- loading-bitmap' )
    set-bitfield-widths
    dup header>> bit-count>> {
        { 16 [
            dup bitfields>> '[
                byte-array>ushort-array _ uncompress-bitfield
            ] change-color-index
        ] }
        { 32 [
            dup bitfields>> '[
                byte-array>uint-array _ uncompress-bitfield
            ] change-color-index
        ] }
        [ unsupported-bitfield-widths ]
    } case ;

ERROR: unsupported-bitmap-compression compression ;

GENERIC: uncompress-bitmap* ( loading-bitmap header -- loading-bitmap )

: uncompress-bitmap ( loading-bitmap -- loading-bitmap )
    dup header>> uncompress-bitmap* ;

M: os2-header uncompress-bitmap* ( loading-bitmap header -- loading-bitmap' )
    drop ;

M: v-header uncompress-bitmap* ( loading-bitmap header -- loading-bitmap' )
    compression>> {
        { f [ ] }
        { 0 [ ] }
        { 1 [ [ run-length-uncompress ] change-color-index ] }
        { 2 [ [ 4 b:byte-array-n>seq run-length-uncompress >byte-array ] change-color-index ] }
        { 3 [ uncompress-bitfield-widths ] }
        { 4 [ "jpeg" unsupported-bitmap-compression ] }
        { 5 [ "png" unsupported-bitmap-compression ] }
    } case ;

: bitmap-padding ( width -- n )
    3 * 4 mod 4 swap - 4 mod ; inline

: loading-bitmap>bytes ( loading-bitmap -- byte-array )
    uncompress-bitmap
    bitmap>bytes ;

: color-palette-length ( loading-bitmap -- n )
    file-header>>
    [ offset>> 14 - ] [ header-length>> ] bi - ;

: color-index-length ( header -- n )
    {
        [ width>> ]
        [ planes>> * ]
        [ bit-count>> * 31 + 32 /i 4 * ]
        [ height>> abs * ]
    } cleave ;

ERROR: unsupported-bitmap-file magic ;

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

: reverse-lines ( byte-array width -- byte-array )
    <sliced-groups> <reversed> concat ; inline

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

                ! image-size
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
