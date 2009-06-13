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


: zlib-data ( loading-png -- bytes ) 
    chunks>> [ type>> "IDAT" = ] find nip data>> ;

ERROR: unknown-color-type n ;
ERROR: unimplemented-color-type image ;

: inflate-data ( loading-png -- bytes )
    zlib-data zlib-inflate ; 

: decode-greyscale ( loading-png -- loading-png )
    unimplemented-color-type ;

: png-image-bytes ( loading-png -- byte-array )
    [ inflate-data ] [ width>> 3 * 1 + ] bi group
    reverse-png-filter ;

: decode-truecolor ( loading-png -- loading-png )
    [ <image> ] dip {
        [ png-image-bytes >>bitmap ]
        [ [ width>> ] [ height>> ] bi 2array >>dim ]
        [ drop RGB >>component-order ]
    } cleave ;
    
: decode-indexed-color ( loading-png -- loading-png )
    unimplemented-color-type ;

: decode-greyscale-alpha ( loading-png -- loading-png )
    unimplemented-color-type ;

: decode-truecolor-alpha ( loading-png -- loading-png )
    unimplemented-color-type ;

: decode-png ( loading-png -- loading-png ) 
    dup color-type>> {
        { 0 [ decode-greyscale ] }
        { 2 [ decode-truecolor ] }
        { 3 [ decode-indexed-color ] }
        { 4 [ decode-greyscale-alpha ] }
        { 6 [ decode-truecolor-alpha ] }
        [ unknown-color-type ]
    } case ;

: load-png ( path -- image )
    binary stream-throws <limited-file-reader> [
        <loading-png>
        read-png-header
        read-png-chunks
        parse-ihdr-chunk
        decode-png
    ] with-input-stream ;

M: png-image load-image*
    drop load-png ;
