! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays byte-arrays columns
combinators fry grouping io io.binary io.encodings.binary
io.files kernel libc macros math math.bitwise math.functions
namespaces opengl opengl.gl prettyprint sequences strings
summary ui ui.gadgets.panes ;
IN: graphics.bitmap

! Currently can only handle 24/32bit bitmaps.
! Handles row-reversed bitmaps (their height is negative)

TUPLE: bitmap magic size reserved offset header-length width
height planes bit-count compression size-image
x-pels y-pels color-used color-important rgb-quads color-index
alpha-channel-zero?
array ;

: array-copy ( bitmap array -- bitmap array' )
    over size-image>> abs memory>byte-array ;

MACRO: (nbits>bitmap) ( bits -- )
    [ -3 shift ] keep '[
        bitmap new
            2over * _ * >>size-image
            swap >>height
            swap >>width
            swap array-copy [ >>array ] [ >>color-index ] bi
            _ >>bit-count
    ] ;

: bgr>bitmap ( array height width -- bitmap )
    24 (nbits>bitmap) ;

: bgra>bitmap ( array height width -- bitmap )
    32 (nbits>bitmap) ;

: 8bit>array ( bitmap -- array )
    [ rgb-quads>> 4 <sliced-groups> [ 3 head-slice ] map ]
    [ color-index>> >array ] bi [ swap nth ] with map concat ;

ERROR: bmp-not-supported n ;

: raw-bitmap>array ( bitmap -- array )
    dup bit-count>>
    {
        { 32 [ color-index>> ] }
        { 24 [ color-index>> ] }
        { 16 [ bmp-not-supported ] }
        { 8 [ 8bit>array ] }
        { 4 [ bmp-not-supported ] }
        { 2 [ bmp-not-supported ] }
        { 1 [ bmp-not-supported ] }
    } case >byte-array ;

ERROR: bitmap-magic ;

M: bitmap-magic summary
    drop "First two bytes of bitmap stream must be 'BM'" ;

: read2 ( -- n ) 2 read le> ;
: read4 ( -- n ) 4 read le> ;

: parse-file-header ( bitmap -- bitmap )
    2 read >string dup "BM" = [ bitmap-magic ] unless >>magic
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

: rgb-quads-length ( bitmap -- n )
    [ offset>> 14 - ] [ header-length>> ] bi - ;

: color-index-length ( bitmap -- n )
    {
        [ width>> ]
        [ planes>> * ]
        [ bit-count>> * 31 + 32 /i 4 * ]
        [ height>> abs * ]
    } cleave ;

: parse-bitmap ( bitmap -- bitmap )
    dup rgb-quads-length read >>rgb-quads
    dup color-index-length read >>color-index ;

: (load-bitmap) ( path -- bitmap )
    binary [
        bitmap new
        parse-file-header parse-bitmap-header parse-bitmap
    ] with-file-reader ;

: alpha-channel-zero? ( bitmap -- ? )
    array>> 4 <sliced-groups> 3 <column> [ 0 = ] all? ;

: load-bitmap ( path -- bitmap )
    (load-bitmap)
    dup raw-bitmap>array >>array
    dup alpha-channel-zero? >>alpha-channel-zero? ;

: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

: save-bitmap ( bitmap path -- )
    binary [
        B{ CHAR: B CHAR: M } write
        [
            array>> length 14 + 40 + write4
            0 write4
            54 write4
            40 write4
        ] [
            {
                [ width>> write4 ]
                [ height>> write4 ]
                [ planes>> 1 or write2 ]
                [ bit-count>> 24 or write2 ]
                [ compression>> 0 or write4 ]
                [ size-image>> write4 ]
                [ x-pels>> 0 or write4 ]
                [ y-pels>> 0 or write4 ]
                [ color-used>> 0 or write4 ]
                [ color-important>> 0 or write4 ]
                [ rgb-quads>> write ]
                [ color-index>> write ]
            } cleave
        ] bi
    ] with-file-writer ;
