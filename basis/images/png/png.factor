! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays checksums checksums.crc32 combinators
compression.inflate fry grouping images images.loader io
io.binary io.encodings.ascii io.encodings.string kernel locals
math math.bitwise math.ranges sequences sorting assocs
math.functions math.order byte-arrays ;
QUALIFIED-WITH: bitstreams bs
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

CONSTANT: interlace-none 0
CONSTANT: interlace-adam7 1

CONSTANT: starting-row  { 0 0 4 0 2 0 1 }
CONSTANT: starting-col  { 0 4 0 2 0 1 0 }
CONSTANT: row-increment { 8 8 8 4 4 2 2 }
CONSTANT: col-increment { 8 8 4 4 2 2 1 }
CONSTANT: block-height  { 8 8 4 4 2 2 1 }
CONSTANT: block-width   { 8 4 4 2 2 1 1 }

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

: find-chunks ( loading-png string -- chunk )
    [ chunks>> ] dip '[ type>> _ = ] filter ;

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
    "IDAT" find-chunks [ data>> ] map concat ;

ERROR: unknown-color-type n ;
ERROR: unimplemented-color-type image ;

: inflate-data ( loading-png -- bytes )
    find-compressed-bytes zlib-inflate ;

: png-components-per-pixel ( loading-png -- n )
    color-type>> {
        { greyscale [ 1 ] }
        { truecolor [ 3 ] }
        { greyscale-alpha [ 2 ] }
        { indexed-color [ 1 ] }
        { truecolor-alpha [ 4 ] }
        [ unknown-color-type ]
    } case ; inline

: png-group-width ( loading-png -- n )
    ! 1 + is for the filter type, 1 byte preceding each line
    [ [ png-components-per-pixel ] [ bit-depth>> ] bi * ]
    [ width>> ] bi * 1 + ;

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

:: reverse-png-filter ( lines n -- byte-array )
    lines dup first length 0 <array> prefix
    [ n 1 - 0 <array> prepend ] map
    2 clump [
        n swap first2
        [ ]
        [ n 1 - swap nth ]
        [ [ 0 n 1 - ] dip set-nth ] tri
        png-unfilter-line
    ] map B{ } concat-as ;

:: visit ( row col height width pixel image -- )
    row image nth :> irow
    pixel col irow set-nth ;

ERROR: bad-filter n ;

:: reverse-interlace-none ( byte-array loading-png -- array )
    byte-array bs:<msb0-bit-reader> :> bs
    loading-png width>> :> width
    loading-png height>> :> height
    loading-png png-components-per-pixel :> #components
    loading-png bit-depth>> :> bit-depth
    bit-depth :> depth!
    #components width * :> count!

    ! Only read up to 8 bits at a time
    bit-depth 16 = [
        8 depth!
        count 2 * count!
    ] when

    height [
        8 bs bs:read dup 0 4 between? [ bad-filter ] unless
        count [ depth bs bs:read ] replicate swap prefix
        8 bs bs:align
    ] replicate
    #components bit-depth 16 = [ 2 * ] when reverse-png-filter ;

:: reverse-interlace-adam7 ( byte-array loading-png -- byte-array )
    byte-array bs:<msb0-bit-reader> :> bs
    loading-png height>> :> height
    loading-png width>> :> width
    loading-png bit-depth>> :> bit-depth
    loading-png png-components-per-pixel :> #bytes
    width height #bytes * * <byte-array> width <sliced-groups> :> image

    0 :> row!
    0 :> col!

    0 :> pass!
    [ pass 7 < ] [
        pass starting-row nth row!
        [
            row height <
        ] [
            pass starting-col nth col!
            [
                col width <
            ] [
                row
                col

                pass block-height nth
                height row - min

                pass block-width nth
                width col - min

                bit-depth bs bs:read
                image
                visit

                col pass col-increment nth + col!
            ] while
            row pass row-increment nth + row!
        ] while
        pass 1 + pass!
    ] while
    bit-depth 16 = [
        image { } concat-as
        [ 2 >be ] map B{ } concat-as
    ] [
        image B{ } concat-as
    ] if ;

ERROR: unimplemented-interlace ;

: uncompress-bytes ( loading-png -- bitstream )
    [ inflate-data ] [ ] [ interlace-method>> ] tri {
        { interlace-none [ reverse-interlace-none ] }
        { interlace-adam7 [ "adam7 is broken" throw reverse-interlace-adam7 ] }
        [ unimplemented-interlace ]
    } case ;

ERROR: unknown-component-type n ;

: png-component ( loading-png -- obj )
    bit-depth>> {
        { 1 [ ubyte-components ] }
        { 2 [ ubyte-components ] }
        { 4 [ ubyte-components ] }
        { 8 [ ubyte-components ] }
        { 16 [ ushort-components ] }
        [ unknown-component-type ]
    } case ;

: scale-factor ( n -- n' )
    {
        { 1 [ 255 ] }
        { 2 [ 127 ] }
        { 4 [ 17 ] }
    } case ;

: scale-greyscale ( byte-array loading-png -- byte-array' )
    bit-depth>> {
        { 8 [ ] }
        { 16 [ 2 group [ swap ] assoc-map B{ } concat-as ] }
        [ scale-factor '[ _ * ] B{ } map-as ]
    } case ;

: decode-greyscale ( loading-png -- byte-array )
    [ uncompress-bytes ] keep scale-greyscale ;

: decode-greyscale-alpha ( loading-image -- byte-array )
    [ uncompress-bytes ] [ bit-depth>> ] bi 16 = [
        4 group [ first4 [ swap ] 2dip 4array ] map B{ } concat-as
    ] when ;

ERROR: invalid-PLTE array ;

: verify-PLTE ( seq -- seq )
    dup length 3 divisor? [ invalid-PLTE ] unless ;

: decode-indexed-color ( loading-image -- byte-array )
    [ uncompress-bytes ] keep
    "PLTE" find-chunk data>> verify-PLTE
    3 group '[ _ nth ] { } map-as B{ } concat-as ;

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

: loading-png>bitmap ( loading-png -- bytes component-order )
    dup color-type>> {
        { greyscale [
            validate-greyscale decode-greyscale L
        ] }
        { truecolor [
            validate-truecolor uncompress-bytes RGB
        ] }
        { indexed-color [
            validate-indexed-color decode-indexed-color RGB
        ] }
        { greyscale-alpha [
            validate-greyscale-alpha decode-greyscale-alpha LA
        ] }
        { truecolor-alpha [
            validate-truecolor-alpha uncompress-bytes RGBA
        ] }
        [ unknown-color-type ]
    } case ;

: loading-png>image ( loading-png -- image )
    [ image new ] dip {
        [ loading-png>bitmap [ >>bitmap ] [ >>component-order ] bi* ]
        [ [ width>> ] [ height>> ] bi 2array >>dim ]
        [ png-component >>component-type ]
    } cleave ;

: load-png ( stream -- loading-png )
    [
        <loading-png>
        read-png-header
        read-png-chunks
        parse-ihdr-chunk
    ] with-input-stream ;

M: png-image stream>image
    drop load-png loading-png>image ;
