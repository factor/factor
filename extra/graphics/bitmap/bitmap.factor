! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: alien arrays byte-arrays combinators
graphics.viewer io io.binary io.files kernel libc math
math.functions namespaces opengl opengl.gl prettyprint
sequences strings ui ui.gadgets.panes ;
IN: graphics.bitmap

! Currently can only handle 24bit bitmaps.
! Handles row-reversed bitmaps (their height is negative)

TUPLE: bitmap magic size reserved offset header-length width
    height planes bit-count compression size-image
    x-pels y-pels color-used color-important rgb-quads color-index array ;

: raw-bitmap>string ( str n -- str )
    {
        { 32 [ "32bit" throw ] }
        { 24 [ ] }
        { 16 [ "16bit" throw ] }
        { 8 [ "8bit" throw ] }
        { 4 [ "4bit" throw ] }
        { 2 [ "2bit" throw ] }
        { 1 [ "1bit" throw ] }
    } case ;

: parse-file-header ( bitmap -- )
    2 read [ over set-bitmap-magic ] keep "BM" = [
        "BITMAPFILEHEADER: First two bytes must be BM" throw
    ] unless
    4 read le> over set-bitmap-size
    4 read le> over set-bitmap-reserved
    4 read le> swap set-bitmap-offset ;

: parse-bitmap-header ( bitmap -- )
    4 read le> over set-bitmap-header-length
    4 read le> over set-bitmap-width
    4 read le> over set-bitmap-height
    2 read le> over set-bitmap-planes
    2 read le> over set-bitmap-bit-count
    4 read le> over set-bitmap-compression
    4 read le> over set-bitmap-size-image
    4 read le> over set-bitmap-x-pels
    4 read le> over set-bitmap-y-pels
    4 read le> over set-bitmap-color-used
    4 read le> swap set-bitmap-color-important ;

: rgb-quads-length ( bitmap -- n )
    [ bitmap-offset 14 - ] keep bitmap-header-length - ;

: color-index-length ( bitmap -- n )
    [ bitmap-width ] keep [ bitmap-planes * ] keep
    [ bitmap-bit-count * 31 + 32 /i 4 * ] keep
    bitmap-height abs * ;

: parse-bitmap ( bitmap -- )
    dup rgb-quads-length read over set-bitmap-rgb-quads
    dup color-index-length read swap set-bitmap-color-index ;

: load-bitmap ( path -- bitmap )
    <file-reader> [
        T{ bitmap } clone
        dup parse-file-header
        dup parse-bitmap-header
        dup parse-bitmap
    ] with-stream
    dup bitmap-color-index over bitmap-bit-count
    raw-bitmap>string >byte-array over set-bitmap-array ;

: save-bitmap ( bitmap path -- )
    <file-writer> [
        "BM" write
        dup bitmap-array length 14 + 40 + 4 >le write
        0 4 >le write
        54 4 >le write

        40 4 >le write
        dup bitmap-width 4 >le write
        dup bitmap-height 4 >le write
        dup bitmap-planes 1 or 2 >le write
        dup bitmap-bit-count 24 or 2 >le write
        dup bitmap-compression 0 or 4 >le write
        dup bitmap-size-image 4 >le write
        dup bitmap-x-pels 4 >le write
        dup bitmap-y-pels 4 >le write
        dup bitmap-color-used 4 >le write
        dup bitmap-color-important 4 >le write
        dup bitmap-rgb-quads write
        bitmap-color-index write
    ] with-stream ;

M: bitmap draw-image ( bitmap -- )
    dup bitmap-height 0 < [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
    ] [
        0 over bitmap-height abs glRasterPos2i
        1.0 1.0 glPixelZoom
    ] if
    [ bitmap-width ] keep
    [
        [ bitmap-height abs ] keep
        bitmap-bit-count {
            ! { 32 [ GL_BGRA GL_UNSIGNED_INT_8_8_8_8 ] } ! broken
            { 24 [ GL_BGR GL_UNSIGNED_BYTE ] }
        } case
    ] keep bitmap-array glDrawPixels ;

M: bitmap width ( bitmap -- ) bitmap-width ;
M: bitmap height ( bitmap -- ) bitmap-height ;

: bitmap. ( path -- )
    load-bitmap <graphics-gadget> gadget. ;

: bitmap-window ( path -- )
    load-bitmap [ <graphics-gadget> "bitmap" open-window ] keep ;

: test-bitmap24 ( -- )
    "misc/graphics/bmps/thiswayup24.bmp" resource-path bitmap. ;

: test-bitmap8 ( -- )
    "misc/graphics/bmps/rgb8bit.bmp" resource-path bitmap. ;

: test-bitmap4 ( -- )
    "misc/graphics/bmps/rgb4bit.bmp" resource-path
    load-bitmap ;
    ! bitmap. ;

: test-bitmap1 ( -- )
    "misc/graphics/bmps/1bit.bmp" resource-path bitmap. ;

