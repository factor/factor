! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs checksums
checksums.crc32 combinators compression.inflate endian grouping
images images.loader io io.encodings.ascii io.encodings.binary
io.encodings.latin1 io.encodings.string io.streams.byte-array
io.streams.throwing kernel math math.bitwise math.functions
sequences sorting ;
QUALIFIED: bitstreams
IN: images.png

SINGLETON: png-image
"png" png-image ?register-image-class

TUPLE: icc-profile name data ;

TUPLE: itext keyword language translated-keyword text ;

TUPLE: loading-png
    chunks
    width height bit-depth color-type compression-method
    filter-method interlace-method icc-profile itexts ;

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

TUPLE: png-chunk type data ;

: <png-chunk> ( -- png-chunk )
    png-chunk new ; inline

CONSTANT: png-header
    B{ 0x89 0x50 0x4e 0x47 0x0d 0x0a 0x1a 0x0a }

ERROR: bad-png-header header ;

: read-png-header ( -- )
    8 read dup png-header sequence= [
        bad-png-header
    ] unless drop ;

ERROR: bad-checksum ;

: read-png-chunks ( loading-png -- loading-png )
    <png-chunk>
    4 read be> 4 +
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

: read-png-string ( -- str )
    { 0 } read-until drop latin1 decode ;

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

: <icc-profile> ( byte-array -- icc-profile )
    binary [
        read-png-string read1 drop read-contents zlib-inflate
    ] with-byte-reader icc-profile boa ;

: <itext> ( byte-array -- itext )
    binary [
        read-png-string
        ! Skip compression flag and method
        read1 read1 2drop
        read-png-string read-png-string read-png-string
    ] with-byte-reader itext boa ;

: parse-iccp-chunk ( loading-png -- loading-png )
    dup "iCCP" find-chunk [
        data>> <icc-profile> >>icc-profile
    ] when* ;

: parse-itext-chunks ( loading-png -- loading-png )
    dup "iTXt" find-chunks [ data>> <itext> ] map >>itexts ;

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

ERROR: bad-filter n ;

:: png-unfilter-line ( width prev curr filter -- curr' )
    prev :> c
    prev width tail-slice :> b
    curr :> a
    curr width tail-slice :> x
    x length <iota>
    filter {
        { filter-none [ drop ] }
        { filter-sub [ [| n | n x nth n a nth + 256 wrap n x set-nth ] each ] }
        { filter-up [ [| n | n x nth n b nth + 256 wrap n x set-nth ] each ] }
        { filter-average [ [| n | n x nth n a nth n b nth + 2/ + 256 wrap n x set-nth ] each ] }
        { filter-paeth [ [| n | n x nth n a nth n b nth n c nth paeth + 256 wrap n x set-nth ] each ] }
        [ bad-filter ]
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

:: read-scanlines ( byte-reader loading-png width height -- array )
    loading-png png-components-per-pixel :> #components
    loading-png bit-depth>> :> bit-depth
    bit-depth :> depth!
    #components width * :> count!

    #components bit-depth * width * 8 math:align 8 /i :> stride

    height [
        stride 1 + byte-reader stream-read
    ] replicate
    #components bit-depth 16 = [ 2 * ] when reverse-png-filter

    ! Only read up to 8 bits at a time
    bit-depth 16 = [
        8 depth!
        count 2 * count!
    ] when

    bitstreams:<msb0-bit-reader> :> br
    height [
        count [ depth br bitstreams:read ] B{ } replicate-as
        8 br bitstreams:align
    ] replicate concat ;

:: reverse-interlace-none ( bytes loading-png -- array )
    bytes binary <byte-reader> :> br
    loading-png width>> :> width
    loading-png height>> :> height
    br loading-png width height read-scanlines ;

:: adam7-subimage-height ( png-height pass -- subimage-height )
    pass starting-row nth png-height >= [
        0
    ] [
        png-height 1 -
        pass block-height nth +
        pass row-increment nth /i
    ] if ;

:: adam7-subimage-width ( png-width pass -- subimage-width )
    pass starting-col nth png-width >= [
        0
    ] [
        png-width 1 -
        pass block-width nth +
        pass col-increment nth /i
    ] if ;

:: read-adam7-subimage ( byte-reader loading-png pass -- lines )
    loading-png height>> pass adam7-subimage-height :> height
    loading-png width>> pass adam7-subimage-width :> width

    height width * zero? [
        B{ }
    ] [
        byte-reader loading-png width height read-scanlines
    ] if ;

:: reverse-interlace-adam7 ( byte-array loading-png -- byte-array )
    byte-array binary <byte-reader> :> ba
    loading-png height>> :> height
    loading-png width>> :> width
    loading-png bit-depth>> :> bit-depth
    loading-png png-components-per-pixel :> #bytes!
    width height * f <array> width <groups> :> image

    bit-depth 16 = [
        #bytes 2 * #bytes!
    ] when

    0 :> row!
    0 :> col!

    0 :> pass!
    [ pass 7 < ] [
      ba loading-png pass read-adam7-subimage

      #bytes <groups>

      pass starting-row nth row!
      pass starting-col nth col!
      [
          [ row col f f ] dip image visit

          col pass col-increment nth + col!
          col width >= [
              pass starting-col nth col!
              row pass row-increment nth + row!
          ] when
      ] each

      pass 1 + pass!
    ] while
    image concat B{ } concat-as ;

ERROR: unimplemented-interlace ;

: uncompress-bytes ( loading-png -- bitstream )
    [ inflate-data ] [ ] [ interlace-method>> ] tri {
        { interlace-none [ reverse-interlace-none ] }
        { interlace-adam7 [ reverse-interlace-adam7 ] }
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
        { 2 [ 85 ] }
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
        [
            <loading-png>
            read-png-header
            read-png-chunks
            parse-ihdr-chunk
            parse-iccp-chunk
            parse-itext-chunks
        ] throw-on-eof
    ] with-input-stream ;

M: png-image stream>image*
    drop load-png loading-png>image ;
