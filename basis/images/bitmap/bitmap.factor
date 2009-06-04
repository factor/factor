! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays byte-arrays columns
combinators compression.run-length endian fry grouping images
images.loader io io.binary io.encodings.binary io.files
io.streams.limited kernel locals macros math math.bitwise
math.functions namespaces sequences specialized-arrays.uint
specialized-arrays.ushort strings summary io.encodings.8-bit
io.encodings.string ;
QUALIFIED-WITH: bitstreams b
IN: images.bitmap

: read2 ( -- n ) 2 read le> ;
: read4 ( -- n ) 4 read le> ;
: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

TUPLE: bitmap-image < image ;

TUPLE: loading-bitmap 
magic size reserved1 reserved2 offset header-length width
height planes bit-count compression size-image
x-pels y-pels color-used color-important
red-mask green-mask blue-mask alpha-mask
cs-type end-points
gamma-red gamma-green gamma-blue
intent profile-data profile-size reserved3
color-palette color-index bitfields ;

! endpoints-triple is ciexyzX/Y/Z, 3x fixed-point-2.30 aka 3x uint

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
    dup header-length>> {
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
    dup bit-count>>
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
        { 4 [ [ 4 b:byte-array-n>seq ] change-color-index color-lookup ] }
        { 1 [ [ 1 b:byte-array-n>seq ] change-color-index color-lookup ] }
        [ bmp-not-supported ]
    } case >byte-array ;

: set-bitfield-widths ( loading-bitmap -- loading-bitmap' )
    dup bit-count>> {
        { 16 [ dup color-palette>> 4 group [ le> ] map ] }
        { 32 [ { HEX: ff0000 HEX: ff00 HEX: ff } ] }
    } case reverse >>bitfields ;

ERROR: unsupported-bitfield-widths n ;

M: unsupported-bitfield-widths summary
    drop "Bitmaps only support bitfield compression in 16/32bit images" ;

: uncompress-bitfield-widths ( loading-bitmap -- loading-bitmap' )
    set-bitfield-widths
    dup bit-count>> {
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

: uncompress-bitmap ( loading-bitmap -- loading-bitmap' )
    dup compression>> {
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

: parse-file-header ( loading-bitmap -- loading-bitmap )
    2 read latin1 decode >>magic
    read4 >>size
    read2 >>reserved1
    read2 >>reserved2
    read4 >>offset ;

: read-v3-header ( loading-bitmap -- loading-bitmap )
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

: read-v4-header ( loading-bitmap -- loading-bitmap )
    read-v3-header
    read4 >>red-mask
    read4 >>green-mask
    read4 >>blue-mask
    read4 >>alpha-mask
    read4 >>cs-type
    read4 read4 read4 3array >>end-points
    read4 >>gamma-red
    read4 >>gamma-green
    read4 >>gamma-blue ;

: read-v5-header ( loading-bitmap -- loading-bitmap )
    read-v4-header
    read4 >>intent
    read4 >>profile-data
    read4 >>profile-size
    read4 >>reserved3 ;

: read-os2-header ( loading-bitmap -- loading-bitmap )
    read2 >>width
    read2 16 >signed >>height
    read2 >>planes
    read2 >>bit-count ;

: read-os2v2-header ( loading-bitmap -- loading-bitmap )
    read4 >>width
    read4 32 >signed >>height
    read2 >>planes
    read2 >>bit-count ;

ERROR: unknown-bitmap-header n ;

: parse-bitmap-header ( loading-bitmap -- loading-bitmap )
    read4 [ >>header-length ] keep
    {
        { 12 [ read-os2-header ] }
        { 64 [ read-os2v2-header ] }
        { 40 [ read-v3-header ] }
        { 108 [ read-v4-header ] }
        { 124 [ read-v5-header ] }
        [ unknown-bitmap-header ]
    } case ;

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

: parse-bitmap ( loading-bitmap -- loading-bitmap )
    dup color-palette-length read >>color-palette
    dup size-image>> dup 0 > [
        read >>color-index
    ] [
        drop dup color-index-length read >>color-index
    ] if ;

ERROR: unsupported-bitmap-file magic ;

: load-bitmap ( path -- loading-bitmap )
    binary stream-throws <limited-file-reader> [
        loading-bitmap new
        parse-file-header dup magic>> {
            { "BM" [ parse-bitmap-header parse-bitmap ] }
            ! { "BA" [ parse-os2-bitmap-array ] }
            ! { "CI" [ parse-os2-color-icon ] }
            ! { "CP" [ parse-os2-color-pointer ] }
            ! { "IC" [ parse-os2-icon ] }
            ! { "PT" [ parse-os2-pointer ] }
            [ unsupported-bitmap-file ]
        } case 
    ] with-input-stream ;

ERROR: unknown-component-order bitmap ;

: bitmap>component-order ( loading-bitmap -- object )
    bit-count>> {
        { 32 [ BGR ] }
        { 24 [ BGR ] }
        { 16 [ BGR ] }
        { 8 [ BGR ] }
        { 4 [ BGR ] }
        { 1 [ BGR ] }
        [ unknown-component-order ]
    } case ;

: loading-bitmap>image ( image loading-bitmap -- bitmap-image )
    {
        [ loading-bitmap>bytes >>bitmap ]
        [ [ width>> ] [ height>> abs ] bi 2array >>dim ]
        [ height>> 0 < not >>upside-down? ]
        [ compression>> 3 = [ t >>upside-down? ] when ]
        [ bitmap>component-order >>component-order ]
    } cleave ;

M: bitmap-image load-image* ( path loading-bitmap -- bitmap )
    swap load-bitmap loading-bitmap>image ;

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
