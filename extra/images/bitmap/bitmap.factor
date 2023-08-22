! Copyright (C) 2007, 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays
byte-arrays combinators compression.run-length endian grouping
images images.loader images.normalization io io.encodings.latin1
io.encodings.string io.streams.throwing kernel math math.bitwise
sequences specialized-arrays summary ;
QUALIFIED-WITH: bitstreams b
SPECIALIZED-ARRAYS: uint ushort ;
IN: images.bitmap

! https://www.fileformat.info/format/bmp/egff.htm
! https://www.digicamsoft.com/bmp/bmp.html

SINGLETON: bmp-image
"bmp" bmp-image ?register-image-class

: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

ERROR: unknown-component-order bitmap ;
ERROR: unknown-bitmap-header n ;

: read2 ( -- n ) 2 read le> ;
: read4 ( -- n ) 4 read le> ;

TUPLE: loading-bitmap
    file-header header
    color-palette color-index bitfields ;

TUPLE: file-header
    { magic initial: "BM" }
    { size }
    { reserved1 initial: 0 }
    { reserved2 initial: 0 }
    { offset }
    { header-length } ;

TUPLE: v3-header
    { width initial: 0 }
    { height initial: 0 }
    { planes initial: 0 }
    { bit-count initial: 0 }
    { compression initial: 0 }
    { image-size initial: 0 }
    { x-resolution initial: 0 }
    { y-resolution initial: 0 }
    { colors-used initial: 0 }
    { colors-important initial: 0 } ;

TUPLE: v4-header < v3-header
    { red-mask initial: 0 }
    { green-mask initial: 0 }
    { blue-mask initial: 0 }
    { alpha-mask initial: 0 }
    { cs-type initial: 0 }
    { end-points initial: 0 }
    { gamma-red initial: 0 }
    { gamma-green initial: 0 }
    { gamma-blue initial: 0 } ;

TUPLE: v5-header < v4-header
    { intent initial: 0 }
    { profile-data initial: 0 }
    { profile-size initial: 0 }
    { reserved3 initial: 0 } ;

TUPLE: os2v1-header
    { width initial: 0 }
    { height initial: 0 }
    { planes initial: 0 }
    { bit-count initial: 0 } ;

TUPLE: os2v2-header < os2v1-header
    { compression initial: 0 }
    { image-size initial: 0 }
    { x-resolution initial: 0 }
    { y-resolution initial: 0 }
    { colors-used initial: 0 }
    { colors-important initial: 0 }
    { units initial: 0 }
    { reserved initial: 0 }
    { recording initial: 0 }
    { rendering initial: 0 }
    { size1 initial: 0 }
    { size2 initial: 0 }
    { color-encoding initial: 0 }
    { identifier initial: 0 } ;

UNION: v-header v3-header v4-header v5-header ;
UNION: os2-header os2v1-header os2v2-header ;

: parse-file-header ( -- file-header )
    \ file-header new
        2 read latin1 decode >>magic
        read4 >>size
        read2 >>reserved1
        read2 >>reserved2
        read4 >>offset
        read4 >>header-length ;

: read-v3-header-data ( header -- header )
    read4 >>width
    read4 32 >signed >>height
    read2 >>planes
    read2 >>bit-count
    read4 >>compression
    read4 >>image-size
    read4 >>x-resolution
    read4 >>y-resolution
    read4 >>colors-used
    read4 >>colors-important ;

: read-v3-header ( -- header )
    \ v3-header new
        read-v3-header-data ;

: read-v4-header-data ( header -- header )
    read4 >>red-mask
    read4 >>green-mask
    read4 >>blue-mask
    read4 >>alpha-mask
    read4 >>cs-type
    read4 read4 read4 3array >>end-points
    read4 >>gamma-red
    read4 >>gamma-green
    read4 >>gamma-blue ;

: read-v4-header ( -- v4-header )
    \ v4-header new
        read-v3-header-data
        read-v4-header-data ;

: read-v5-header-data ( v5-header -- v5-header )
    read4 >>intent
    read4 >>profile-data
    read4 >>profile-size
    read4 >>reserved3 ;

: read-v5-header ( -- loading-bitmap )
    \ v5-header new
        read-v3-header-data
        read-v4-header-data
        read-v5-header-data ;

: read-os2v1-header ( -- os2v1-header )
    \ os2v1-header new
        read2 >>width
        read2 16 >signed >>height
        read2 >>planes
        read2 >>bit-count ;

: read-os2v2-header-data ( os2v2-header -- os2v2-header )
    read4 >>width
    read4 32 >signed >>height
    read2 >>planes
    read2 >>bit-count
    read4 >>compression
    read4 >>image-size
    read4 >>x-resolution
    read4 >>y-resolution
    read4 >>colors-used
    read4 >>colors-important
    read2 >>units
    read2 >>reserved
    read2 >>recording
    read2 >>rendering
    read4 >>size1
    read4 >>size2
    read4 >>color-encoding
    read4 >>identifier ;

: read-os2v2-header ( -- os2v2-header )
    \ os2v2-header new
        read-os2v2-header-data ;

: parse-header ( n -- header )
    {
        { 12 [ read-os2v1-header ] }
        { 64 [ read-os2v2-header ] }
        { 40 [ read-v3-header ] }
        { 108 [ read-v4-header ] }
        { 124 [ read-v5-header ] }
        [ unknown-bitmap-header ]
    } case ;

: color-index-length ( header -- n )
    {
        [ width>> ]
        [ planes>> * ]
        [ bit-count>> * 31 + 32 /i 4 * ]
        [ height>> abs * ]
    } cleave ;

: color-palette-length ( loading-bitmap -- n )
    file-header>>
    [ offset>> 14 - ] [ header-length>> ] bi - ;

: parse-color-palette ( loading-bitmap -- loading-bitmap )
    dup color-palette-length read >>color-palette ;

GENERIC: parse-color-data* ( loading-bitmap header -- loading-bitmap )

: parse-color-data ( loading-bitmap -- loading-bitmap )
    dup header>> parse-color-data* ;

M: os2v1-header parse-color-data* ( loading-bitmap header -- loading-bitmap )
    color-index-length read >>color-index ;

M: object parse-color-data* ( loading-bitmap header -- loading-bitmap )
    dup image-size>> [ 0 ] unless* dup 0 >
    [ nip ] [ drop color-index-length ] if read >>color-index ;

: alpha-used? ( loading-bitmap -- ? )
    color-index>> 4 <groups> [ fourth 0 = ] all? not ;

GENERIC: bitmap>component-order* ( loading-bitmap header -- object )

: bitmap>component-order ( loading-bitmap -- object )
    dup header>> bitmap>component-order* ;

: simple-bitmap>component-order ( loading-bitamp -- object )
    header>> bit-count>> {
        { 32 [ BGRX ] }
        { 24 [ BGR ] }
        { 16 [ BGR ] }
        { 8 [ BGR ] }
        { 4 [ BGR ] }
        { 1 [ BGR ] }
        [ unknown-component-order ]
    } case ;

: advanced-bitmap>component-order ( loading-bitmap -- object )
    [ ] [ header>> bit-count>> ] [ alpha-used? ] tri 2array {
        { { 32 t } [ drop BGRA ] }
        { { 32 f } [ drop BGRX ] }
        [ drop simple-bitmap>component-order ]
    } case ;

: color-lookup3 ( loading-bitmap -- seq )
    [ color-index>> >array ]
    [ color-palette>> 3 <groups> ] bi
    '[ _ nth ] map concat ;

: color-lookup4 ( loading-bitmap -- seq )
    [ color-index>> >array ]
    [ color-palette>> 4 <groups> [ 3 head-slice ] map ] bi
    '[ _ nth ] map concat ;

! os2v1 is 3bytes each, all others are 3 + 1 unused
: color-lookup ( loading-bitmap -- seq )
    dup file-header>> header-length>> {
        { 12 [ color-lookup3 ] }
        { 64 [ color-lookup4 ] }
        { 40 [ color-lookup4 ] }
        { 108 [ color-lookup4 ] }
        { 124 [ color-lookup4 ] }
    } case ;

M: os2v1-header bitmap>component-order* drop simple-bitmap>component-order ;
M: os2v2-header bitmap>component-order* drop simple-bitmap>component-order ;
M: v3-header bitmap>component-order* drop simple-bitmap>component-order ;
M: v4-header bitmap>component-order* drop advanced-bitmap>component-order ;
M: v5-header bitmap>component-order* drop advanced-bitmap>component-order ;

: uncompress-bitfield ( seq masks -- bytes' )
    '[
        _ [
            [ bitand ] [ bit-count ] [ log2 ] tri - shift
        ] with map
    ] { } map-as B{ } concat-as ;

ERROR: bmp-not-supported n ;

: bitmap>bytes ( loading-bitmap -- byte-array )
    dup header>> bit-count>>
    {
        { 32 [ color-index>> ] }
        { 24 [ color-index>> ] }
        { 16 [
            [
                ! ushort cast-array
                2 group [ le> ] map
                ! 5 6 5
                ! { 0xf800 0x7e0 0x1f } uncompress-bitfield
                ! 5 5 5
                { 0x7c00 0x3e0 0x1f } uncompress-bitfield
            ] change-color-index
            color-index>>
        ] }
        { 8 [ color-lookup ] }
        { 4 [ [ 4 b:byte-array-n>sequence ] change-color-index color-lookup ] }
        { 1 [ [ 1 b:byte-array-n>sequence ] change-color-index color-lookup ] }
        [ bmp-not-supported ]
    } case >byte-array ;

: set-bitfield-widths ( loading-bitmap -- loading-bitmap' )
    dup header>> bit-count>> {
        { 16 [ dup color-palette>> 4 group [ le> ] map ] }
        { 32 [ { 0xff0000 0xff00 0xff } ] }
    } case reverse >>bitfields ;

ERROR: unsupported-bitfield-widths n ;

M: unsupported-bitfield-widths summary
    drop "Bitmaps only support bitfield compression in 16/32bit images" ;

: uncompress-bitfield-widths ( loading-bitmap -- loading-bitmap' )
    set-bitfield-widths
    dup header>> bit-count>> {
        { 16 [
            dup bitfields>> '[
                ushort cast-array _ uncompress-bitfield
            ] change-color-index
        ] }
        { 32 [ ] }
        [ unsupported-bitfield-widths ]
    } case ;

ERROR: unsupported-bitmap-compression compression ;

GENERIC: uncompress-bitmap* ( loading-bitmap header -- loading-bitmap )

: uncompress-bitmap ( loading-bitmap -- loading-bitmap )
    dup header>> uncompress-bitmap* ;

M: os2-header uncompress-bitmap* ( loading-bitmap header -- loading-bitmap' )
    drop ;

: do-run-length-uncompress ( loading-bitmap word -- loading-bitmap )
    dupd '[
        _ header>> [ width>> ] [ height>> ] bi
        _ execute
    ] change-color-index ; inline

M: v-header uncompress-bitmap* ( loading-bitmap header -- loading-bitmap' )
    compression>> {
        { f [ ] }
        { 0 [ ] }
        { 1 [ \ run-length-uncompress-bitmap8 do-run-length-uncompress ] }
        { 2 [ \ run-length-uncompress-bitmap4 do-run-length-uncompress ] }
        { 3 [ uncompress-bitfield-widths ] }
        { 4 [ "jpeg" unsupported-bitmap-compression ] }
        { 5 [ "png" unsupported-bitmap-compression ] }
    } case ;

ERROR: unsupported-bitmap-file magic ;

: load-bitmap ( stream -- loading-bitmap )
    [
        [
            \ loading-bitmap new
            parse-file-header [ >>file-header ] [ ] bi magic>> {
                { "BM" [
                    dup file-header>> header-length>> parse-header >>header
                    parse-color-palette
                    parse-color-data
                ] }
                ! { "BA" [ parse-os2-bitmap-array ] }
                ! { "CI" [ parse-os2-color-icon ] }
                ! { "CP" [ parse-os2-color-pointer ] }
                ! { "IC" [ parse-os2-icon ] }
                ! { "PT" [ parse-os2-pointer ] }
                [ unsupported-bitmap-file ]
            } case
        ] throw-on-eof
    ] with-input-stream ;

: loading-bitmap>bytes ( loading-bitmap -- byte-array )
    uncompress-bitmap bitmap>bytes ;

M: bmp-image stream>image* ( stream bmp-image -- bitmap )
    drop load-bitmap
    [ image new ] dip
    {
        [ loading-bitmap>bytes >>bitmap ]
        [ header>> [ width>> ] [ height>> abs ] bi 2array >>dim ]
        [ header>> height>> 0 < not >>upside-down? ]
        [ bitmap>component-order >>component-order ubyte-components >>component-type ]
    } cleave ;

: output-width-and-height ( image -- )
    [ dim>> first write4 ]
    [
        [ dim>> second ] [ upside-down?>> ] bi
        [ neg ] unless write4
    ] bi ;

: output-bmp ( image -- )
    B{ CHAR: B CHAR: M } write
    [
        bitmap>> length 14 + 40 + write4
        0 write4
        54 write4
        40 write4
    ] [
        {
            [ output-width-and-height ]

            ! planes
            [ drop 1 write2 ]

            ! bit-count
            [ drop 24 write2 ]

            ! compression
            [ drop 0 write4 ]

            ! image-size
            [ bitmap>> length write4 ]

            ! x-pels
            [ drop 0 write4 ]

            ! y-pels
            [ drop 0 write4 ]

            ! color-used
            [ drop 0 write4 ]

            ! color-important
            [ drop 0 write4 ]

            ! color-palette
            [ bitmap>> write ]
        } cleave
    ] bi ;

M: bmp-image image>stream
    2drop BGR reorder-components output-bmp ;
