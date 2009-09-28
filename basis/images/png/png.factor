! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays checksums checksums.crc32 combinators
compression.inflate fry grouping images images.loader io
io.binary io.encodings.ascii io.encodings.string kernel locals
math math.bitwise math.ranges sequences sorting ;
IN: images.png

SINGLETON: png-image
"png" png-image register-image-class

TUPLE: loading-png
    chunks
    width height bit-depth color-type compression-method
    filter-method interlace-method uncompressed ;

CONSTANT: filter-none 0
CONSTANT: filter-sub 1
CONSTANT: filter-up 2
CONSTANT: filter-average 3
CONSTANT: filter-paeth 4

CONSTANT: greyscale 0
CONSTANT: truecolor 2
CONSTANT: indexed-color 3
CONSTANT: greyscale-alpha 4
CONSTANT: truecolor-alpha 6

: <loading-png> ( -- image )
    loading-png new
    V{ } clone >>chunks ;

TUPLE: png-chunk length type data ;

: <png-chunk> ( -- png-chunk )
    png-chunk new ; inline

CONSTANT: png-header
    B{ HEX: 89 HEX: 50 HEX: 4e HEX: 47 HEX: 0d HEX: 0a HEX: 1a HEX: 0a }

ERROR: bad-png-header header ;

: read-png-header ( -- )
    8 read dup png-header sequence= [
        bad-png-header
    ] unless drop ;

ERROR: bad-checksum ;

: read-png-chunks ( loading-png -- loading-png )
    <png-chunk>
    4 read be> [ >>length ] [ 4 + ] bi
    read dup crc32 checksum-bytes
    4 read = [ bad-checksum ] unless
    4 cut-slice
    [ ascii decode >>type ] [ B{ } like >>data ] bi*
    [ over chunks>> push ] 
    [ type>> ] bi "IEND" =
    [ read-png-chunks ] unless ;

: find-chunk ( loading-png string -- chunk )
    [ chunks>> ] dip '[ type>> _ = ] find nip ;

: parse-ihdr-chunk ( loading-png -- loading-png )
    dup "IHDR" find-chunk data>> {
        [ [ 0 4 ] dip subseq be> >>width ]
        [ [ 4 8 ] dip subseq be> >>height ]
        [ [ 8 ] dip nth >>bit-depth ]
        [ [ 9 ] dip nth >>color-type ]
        [ [ 10 ] dip nth >>compression-method ]
        [ [ 11 ] dip nth >>filter-method ]
        [ [ 12 ] dip nth >>interlace-method ]
    } cleave ;

: find-compressed-bytes ( loading-png -- bytes )
    chunks>> [ type>> "IDAT" = ] filter
    [ data>> ] map concat ;

ERROR: unknown-color-type n ;
ERROR: unimplemented-color-type image ;

: inflate-data ( loading-png -- bytes )
    find-compressed-bytes zlib-inflate ; 

: scale-bit-depth ( loading-png -- n ) bit-depth>> 8 / ; inline

: png-bytes-per-pixel ( loading-png -- n )
    dup color-type>> {
        { 2 [ scale-bit-depth 3 * ] }
        { 6 [ scale-bit-depth 4 * ] }
        [ unknown-color-type ]
    } case ; inline

: png-group-width ( loading-png -- n )
    ! 1 + is for the filter type, 1 byte preceding each line
    [ png-bytes-per-pixel ] [ width>> ] bi * 1 + ;

:: paeth ( a b c -- p ) 
    a b + c - { a b c } [ [ - abs ] keep 2array ] with map 
    sort-keys first second ;

:: png-unfilter-line ( width prev curr filter -- curr' )
    prev :> c
    prev width tail-slice :> b
    curr :> a
    curr width tail-slice :> x
    x length [0,b)
    filter {
        { filter-none [ drop ] }
        { filter-sub [ [| n | n x nth n a nth + 256 wrap n x set-nth ] each ] }
        { filter-up [ [| n | n x nth n b nth + 256 wrap n x set-nth ] each ] }
        { filter-average [ [| n | n x nth n a nth n b nth + 2/ + 256 wrap n x set-nth ] each ] }
        { filter-paeth [ [| n | n x nth n a nth n b nth n c nth paeth + 256 wrap n x set-nth ] each ] }
    } case 
    curr width tail ;

:: reverse-png-filter ( n lines -- byte-array )
    lines dup first length 0 <array> prefix
    [ n 1 - 0 <array> prepend ] map
    2 clump [
        n swap first2 [ ] [ n 1 - swap nth ] [ [ 0 n 1 - ] dip set-nth ] tri
        png-unfilter-line
    ] map B{ } concat-as ;

: png-image-bytes ( loading-png -- byte-array )
    [ png-bytes-per-pixel ] [ inflate-data ] [ png-group-width ] tri group reverse-png-filter ;

: decode-greyscale ( loading-png -- loading-png )
    unimplemented-color-type ;

: decode-truecolor ( loading-png -- loading-png )
    [ <image> ] dip {
        [ png-image-bytes >>bitmap ]
        [ [ width>> ] [ height>> ] bi 2array >>dim ]
        [ drop RGB >>component-order ubyte-components >>component-type ]
    } cleave ;
    
: decode-indexed-color ( loading-png -- loading-png )
    unimplemented-color-type ;

: decode-greyscale-alpha ( loading-png -- loading-png )
    unimplemented-color-type ;

: decode-truecolor-alpha ( loading-png -- loading-png )
    [ <image> ] dip {
        [ png-image-bytes >>bitmap ]
        [ [ width>> ] [ height>> ] bi 2array >>dim ]
        [ drop RGBA >>component-order ubyte-components >>component-type ]
    } cleave ;

ERROR: invalid-color-type/bit-depth loading-png ;

: validate-bit-depth ( loading-png seq -- loading-png )
    [ dup bit-depth>> ] dip member?
    [ invalid-color-type/bit-depth ] unless ;

: validate-greyscale ( loading-png -- loading-png )
    { 1 2 4 8 16 } validate-bit-depth ;

: validate-truecolor ( loading-png -- loading-png )
    { 8 16 } validate-bit-depth ;

: validate-indexed-color ( loading-png -- loading-png )
    { 1 2 4 8 } validate-bit-depth ;

: validate-greyscale-alpha ( loading-png -- loading-png )
    { 8 16 } validate-bit-depth ;

: validate-truecolor-alpha ( loading-png -- loading-png )
    { 8 16 } validate-bit-depth ;

: decode-png ( loading-png -- loading-png ) 
    dup color-type>> {
        { greyscale [ validate-greyscale decode-greyscale ] }
        { truecolor [ validate-truecolor decode-truecolor ] }
        { indexed-color [ validate-indexed-color decode-indexed-color ] }
        { greyscale-alpha [ validate-greyscale-alpha decode-greyscale-alpha ] }
        { truecolor-alpha [ validate-truecolor-alpha decode-truecolor-alpha ] }
        [ unknown-color-type ]
    } case ;

M: png-image stream>image
    drop [
        <loading-png>
        read-png-header
        read-png-chunks
        parse-ihdr-chunk
        decode-png
    ] with-input-stream ;
