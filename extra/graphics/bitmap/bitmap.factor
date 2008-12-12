! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: alien arrays byte-arrays combinators summary io.backend
graphics.viewer io io.binary io.files kernel libc math
math.functions math.bitwise namespaces opengl opengl.gl
prettyprint sequences strings ui ui.gadgets.panes fry
io.encodings.binary accessors grouping macros alien.c-types ;
IN: graphics.bitmap

! Currently can only handle 24/32bit bitmaps.
! Handles row-reversed bitmaps (their height is negative)

TUPLE: bitmap magic size reserved offset header-length width
    height planes bit-count compression size-image
    x-pels y-pels color-used color-important rgb-quads color-index array ;

: (array-copy) ( bitmap array -- bitmap array' )
    over size-image>> abs memory>byte-array ;

MACRO: (nbits>bitmap) ( bits -- )
    [ -3 shift ] keep '[
        bitmap new
            2over * _ * >>size-image
            swap >>height
            swap >>width
            swap (array-copy) [ >>array ] [ >>color-index ] bi
            _ >>bit-count
    ] ;

: bgr>bitmap ( array height width -- bitmap )
    24 (nbits>bitmap) ;

: bgra>bitmap ( array height width -- bitmap )
    32 (nbits>bitmap) ;

: 8bit>array ( bitmap -- array )
    [ rgb-quads>> 4 <sliced-groups> [ 3 head-slice ] map ]
    [ color-index>> >array ] bi [ swap nth ] with map concat ;

: 4bit>array ( bitmap -- array )
    [ rgb-quads>> 4 <sliced-groups> [ 3 head-slice ] map ]
    [ color-index>> >array ] bi [ swap nth ] with map concat ;

: raw-bitmap>array ( bitmap -- array )
    dup bit-count>>
    {
        { 32 [ "32bit" throw ] }
        { 24 [ color-index>> ] }
        { 16 [ "16bit" throw ] }
        { 8 [ 8bit>array ] }
        { 4 [ 4bit>array ] }
        { 2 [ "2bit" throw ] }
        { 1 [ "1bit" throw ] }
    } case >byte-array ;

ERROR: bitmap-magic ;

M: bitmap-magic summary
    drop "First two bytes of bitmap stream must be 'BM'" ;

: parse-file-header ( bitmap -- )
    2 read >string dup "BM" = [ bitmap-magic ] unless >>magic
    4 read le> >>size
    4 read le> >>reserved
    4 read le> >>offset drop ;

: parse-bitmap-header ( bitmap -- )
    4 read le> >>header-length
    4 read signed-le> >>width
    4 read signed-le> >>height
    2 read le> >>planes
    2 read le> >>bit-count
    4 read le> >>compression
    4 read le> >>size-image
    4 read le> >>x-pels
    4 read le> >>y-pels
    4 read le> >>color-used
    4 read le> >>color-important drop ;

: rgb-quads-length ( bitmap -- n )
    [ offset>> 14 - ] keep header-length>> - ;

: color-index-length ( bitmap -- n )
    [ width>> ] keep [ planes>> * ] keep
    [ bit-count>> * 31 + 32 /i 4 * ] keep
    height>> abs * ;

: parse-bitmap ( bitmap -- )
    dup rgb-quads-length read >>rgb-quads
    dup color-index-length read >>color-index drop ;

: load-bitmap ( path -- bitmap )
    normalize-path binary [
        bitmap new
            dup parse-file-header
            dup parse-bitmap-header
            dup parse-bitmap
    ] with-file-reader
    dup raw-bitmap>array >>array ;

: save-bitmap ( bitmap path -- )
    binary [
        "BM" >byte-array write
        dup array>> length 14 + 40 + 4 >le write
        0 4 >le write
        54 4 >le write

        40 4 >le write
        {
            [ width>> 4 >le write ]
            [ height>> 4 >le write ]
            [ planes>> 1 or 2 >le write ]
            [ bit-count>> 24 or 2 >le write ]
            [ compression>> 0 or 4 >le write ]
            [ size-image>> 4 >le write ]
            [ x-pels>> 0 or 4 >le write ]
            [ y-pels>> 0 or 4 >le write ]
            [ color-used>> 0 or 4 >le write ]
            [ color-important>> 0 or 4 >le write ]
            [ rgb-quads>> write ]
            [ color-index>> write ]
        } cleave
    ] with-file-writer ;

M: bitmap draw-image ( bitmap -- )
    dup height>> 0 < [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
    ] [
        0 over height>> abs glRasterPos2i
        1.0 1.0 glPixelZoom
    ] if
    [ width>> ] keep
    [
        [ height>> abs ] keep
        bit-count>> {
            { 32 [ GL_BGRA GL_UNSIGNED_BYTE ] }
            { 24 [ GL_BGR GL_UNSIGNED_BYTE ] }
            { 8 [ GL_BGR GL_UNSIGNED_BYTE ] }
            { 4 [ GL_BGR GL_UNSIGNED_BYTE ] }
        } case
    ] keep array>> glDrawPixels ;

M: bitmap width ( bitmap -- ) width>> ;
M: bitmap height ( bitmap -- ) height>> ;

: bitmap. ( path -- )
    load-bitmap <graphics-gadget> gadget. ;

: bitmap-window ( path -- gadget )
    load-bitmap <graphics-gadget> [ "bitmap" open-window ] keep ;

: test-bitmap24 ( -- )
    "resource:extra/graphics/bitmap/test-images/thiswayup24.bmp" bitmap. ;

: test-bitmap8 ( -- )
    "resource:extra/graphics/bitmap/test-images/rgb8bit.bmp" bitmap. ;

: test-bitmap4 ( -- )
    "resource:extra/graphics/bitmap/test-images/rgb4bit.bmp" bitmap. ;

: test-bitmap1 ( -- )
    "resource:extra/graphics/bitmap/test-images/1bit.bmp" bitmap. ;

