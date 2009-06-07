! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators images images.bitmap
images.bitmap.private io io.binary io.encodings.8-bit
io.encodings.binary io.encodings.string io.streams.limited
kernel math math.bitwise ;
IN: images.bitmap.loading

! http://www.fileformat.info/format/bmp/egff.htm

ERROR: unknown-component-order bitmap ;
ERROR: unknown-bitmap-header n ;

: read2 ( -- n ) 2 read le> ;
: read4 ( -- n ) 4 read le> ;

TUPLE: loading-bitmap
    file-header header
    color-palette color-index bitfields ;

TUPLE: file-header
    magic size reserved1 reserved2 offset header-length ;

TUPLE: v3-header
    width height planes bit-count
    compression image-size x-resolution y-resolution
    colors-used colors-important ;

TUPLE: v4-header < v3-header
    red-mask green-mask blue-mask alpha-mask
    cs-type end-points
    gamma-red gamma-green gamma-blue ;

TUPLE: v5-header < v4-header
    intent profile-data profile-size reserved3 ;

TUPLE: os2v1-header width height planes bit-count ;
TUPLE: os2v2-header < os2v1-header
    compression image-size x-resolution y-resolution
    colors-used colors-important units reserved
    recording rendering size1 size2 color-encoding identifier ;

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
    4 read >>identifier ;

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

: parse-color-palette ( loading-bitmap -- loading-bitmap )
    dup color-palette-length read >>color-palette ;

GENERIC: parse-color-data* ( loading-bitmap header -- loading-bitmap )

: parse-color-data ( loading-bitmap -- loading-bitmap )
    dup header>> parse-color-data* ;

M: os2v1-header parse-color-data* ( loading-bitmap header -- loading-bitmap )
    color-index-length read >>color-index ;

M: object parse-color-data* ( loading-bitmap header -- loading-bitmap )
    dup image-size>> [
        nip
    ] [
        color-index-length
    ] if* read >>color-index ;

: bitmap>component-order ( loading-bitmap -- object )
    header>> bit-count>> {
        { 32 [ BGR ] }
        { 24 [ BGR ] }
        { 16 [ BGR ] }
        { 8 [ BGR ] }
        { 4 [ BGR ] }
        { 1 [ BGR ] }
        [ unknown-component-order ]
    } case ;

ERROR: unsupported-bitmap-file magic ;

: load-bitmap ( path -- loading-bitmap )
    binary stream-throws <limited-file-reader> [
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
    ] with-input-stream ;

M: bitmap-image load-image* ( path bitmap-image -- bitmap )
    drop load-bitmap
    [ image new ] dip
    {
        [ loading-bitmap>bytes >>bitmap ]
        [ header>> [ width>> ] [ height>> abs ] bi 2array >>dim ]
        [ header>> height>> 0 < not >>upside-down? ]
        [ bitmap>component-order >>component-order ]
    } cleave ;
