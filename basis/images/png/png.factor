! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images io io.binary io.encodings.ascii
io.encodings.binary io.encodings.string io.files io.files.info kernel
sequences io.streams.limited fry combinators arrays math checksums
checksums.crc32 compression.inflate grouping byte-arrays images.loader ;
IN: images.png

SINGLETON: png-image
"png" png-image register-image-class

TUPLE: loading-png
    chunks
    width height bit-depth color-type compression-method
    filter-method interlace-method uncompressed ;

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

: png-group-width ( loading-png -- n )
    dup color-type>> {
        { 2 [ [ bit-depth>> 8 / 3 * ] [ width>> ] bi * 1 + ] }
        { 6 [ [ bit-depth>> 8 / 4 * ] [ width>> ] bi * 1 + ] }
        [ unknown-color-type ]
    } case ;

: png-image-bytes ( loading-png -- byte-array )
    [ inflate-data ] [ png-group-width ] bi group
    reverse-png-filter ;

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
        { 0 [ validate-greyscale decode-greyscale ] }
        { 2 [ validate-truecolor decode-truecolor ] }
        { 3 [ validate-indexed-color decode-indexed-color ] }
        { 4 [ validate-greyscale-alpha decode-greyscale-alpha ] }
        { 6 [ validate-truecolor-alpha decode-truecolor-alpha ] }
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
