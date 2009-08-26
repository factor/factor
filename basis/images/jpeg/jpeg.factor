! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays combinators
grouping compression.huffman images
images.processing io io.binary io.encodings.binary io.files
io.streams.byte-array kernel locals math math.bitwise
math.constants math.functions math.matrices math.order
math.ranges math.vectors memoize multiline namespaces
sequences sequences.deep images.loader ;
IN: images.jpeg

QUALIFIED-WITH: bitstreams bs

TUPLE: jpeg-image < image
    { headers }
    { bitstream }
    { color-info initial: { f f f f } }
    { quant-tables initial: { f f } }
    { huff-tables initial: { f f f f } }
    { components } ;

"jpg" jpeg-image register-image-class
"jpeg" jpeg-image register-image-class

<PRIVATE

: <jpeg-image> ( headers bitstream -- image )
    jpeg-image new swap >>bitstream swap >>headers ;

SINGLETONS: SOF DHT DAC RST SOI EOI SOS DQT DNL DRI DHP EXP
APP JPG COM TEM RES ;

! ISO/IEC 10918-1 Table B.1
:: >marker ( byte -- marker )
    byte
    {
      { [ dup HEX: CC = ] [ { DAC } ] }
      { [ dup HEX: C4 = ] [ { DHT } ] }
      { [ dup HEX: C9 = ] [ { JPG } ] }
      { [ dup -4 shift HEX: C = ] [ SOF byte 4 bits 2array ] }

      { [ dup HEX: D8 = ] [ { SOI } ] }
      { [ dup HEX: D9 = ] [ { EOI } ] }
      { [ dup HEX: DA = ] [ { SOS } ] }
      { [ dup HEX: DB = ] [ { DQT } ] }
      { [ dup HEX: DC = ] [ { DNL } ] }
      { [ dup HEX: DD = ] [ { DRI } ] }
      { [ dup HEX: DE = ] [ { DHP } ] }
      { [ dup HEX: DF = ] [ { EXP } ] }
      { [ dup -4 shift HEX: D = ] [ RST byte 4 bits 2array ] }

      { [ dup -4 shift HEX: E = ] [ APP byte 4 bits 2array ] }
      { [ dup HEX: FE = ] [ { COM } ] }
      { [ dup -4 shift HEX: F = ] [ JPG byte 4 bits 2array ] }

      { [ dup HEX: 01 = ] [ { TEM } ] }
      [ { RES } ]
    }
    cond nip ;

TUPLE: jpeg-chunk length type data ;

: <jpeg-chunk> ( type length data -- jpeg-chunk )
    jpeg-chunk new
        swap >>data
        swap >>length
        swap >>type ;

TUPLE: jpeg-color-info
    h v quant-table dc-huff-table ac-huff-table { diff initial: 0 } id ;

: <jpeg-color-info> ( h v quant-table -- jpeg-color-info )
    jpeg-color-info new
        swap >>quant-table
        swap >>v
        swap >>h ;

: jpeg> ( -- jpeg-image ) jpeg-image get ;

: apply-diff ( dc color -- dc' )
    [ diff>> + dup ] [ (>>diff) ] bi ;

: fetch-tables ( component -- )
    [ [ jpeg> quant-tables>> nth ] change-quant-table drop ]
    [ [ jpeg> huff-tables>> nth ] change-dc-huff-table drop ]
    [ [ 2 + jpeg> huff-tables>> nth ] change-ac-huff-table drop ] tri ;

: read4/4 ( -- a b ) read1 16 /mod ;

! headers

: decode-frame ( header -- )
    data>>
    binary
    [
        read1 8 assert=
        2 read be>
        2 read be>
        swap 2array jpeg> (>>dim)
        read1
        [
            read1 read4/4 read1 <jpeg-color-info>
            swap [ >>id ] keep jpeg> color-info>> set-nth
        ] times
    ] with-byte-reader ;

: decode-quant-table ( chunk -- )
    dup data>>
    binary
    [
        length>>
        2 - 65 /
        [
            read4/4 [ 0 assert= ] dip
            64 read
            swap jpeg> quant-tables>> set-nth
        ] times
    ] with-byte-reader ;

: decode-huff-table ( chunk -- )
    data>>
    binary
    [
        1 ! %fixme: Should handle multiple tables at once
        [
            read4/4 swap 2 * +
            16 read
            dup [ ] [ + ] map-reduce read
            binary [ [ read [ B{ } ] unless* ] { } map-as ] with-byte-reader
            swap jpeg> huff-tables>> set-nth
        ] times
    ] with-byte-reader ;

: decode-scan ( chunk -- )
    data>>
    binary
    [
        read1 [0,b)
        [   drop
            read1 jpeg> color-info>> nth clone
            read1 16 /mod [ >>dc-huff-table ] [ >>ac-huff-table ] bi*
        ] map jpeg> (>>components)
        read1 0 assert=
        read1 63 assert=
        read1 16 /mod [ 0 assert= ] bi@
    ] with-byte-reader ;

: singleton-first ( seq -- elt )
    [ length 1 assert= ] [ first ] bi ;

: baseline-parse ( -- )
    jpeg> headers>>
    {
        [ [ type>> { SOF 0 } = ] filter singleton-first decode-frame ]
        [ [ type>> { DQT } = ] filter [ decode-quant-table ] each ]
        [ [ type>> { DHT } = ] filter [ decode-huff-table ] each ]
        [ [ type>> { SOS } = ] filter singleton-first decode-scan ]
    } cleave ;

: parse-marker ( -- marker )
    read1 HEX: FF assert=
    read1 >marker ;

: parse-headers ( -- chunks )
    [ parse-marker dup { SOS } = not ]
    [
        2 read be>
        dup 2 - read <jpeg-chunk>
    ] [ produce ] keep dip swap suffix ;

MEMO: zig-zag ( -- zz )
    {
        {  0  1  5  6 14 15 27 28 }
        {  2  4  7 13 16 26 29 42 }
        {  3  8 12 17 25 30 41 43 }
        {  9 11 18 24 31 40 44 53 }
        { 10 19 23 32 39 45 52 54 }
        { 20 22 33 38 46 51 55 60 }
        { 21 34 37 47 50 56 59 61 }
        { 35 36 48 49 57 58 62 63 }
    } flatten ;

MEMO: yuv>bgr-matrix ( -- m )
    {
        { 1  2.03211  0       }
        { 1 -0.39465 -0.58060 }
        { 1  0        1.13983 }
    } ;

: wave ( x u -- n ) swap 2 * 1 + * pi * 16 / cos ;

:: dct-vect ( u v -- basis )
    { 8 8 } coord-matrix [ { u v } [ wave ] 2map product ] map^2
    1 u v [ 0 = [ 2 sqrt / ] when ] bi@ 4 / m*n ;

MEMO: dct-matrix ( -- m ) 64 [0,b) [ 8 /mod dct-vect flatten ] map ;

: mb-dim ( component -- dim )  [ h>> ] [ v>> ] bi 2array ;

! : blocks ( component -- seq )
!    mb-dim ! coord-matrix flip concat [ [ { 2 2 } v* ] [ v+ ] bi* ] with map ;

: all-macroblocks ( quot: ( mb -- ) -- )
    [
        jpeg>
        [ dim>> 8 v/n ]
        [ color-info>> sift { 0 0 } [ mb-dim vmax ] reduce v/ ] bi
        [ ceiling ] map
        coord-matrix flip concat
    ]
    [ each ] bi* ; inline

: reverse-zigzag ( b -- b' ) zig-zag swap [ nth ] curry map ;

: idct-factor ( b -- b' ) dct-matrix v.m ;

USE: math.blas.vectors
USE: math.blas.matrices

MEMO: dct-matrix-blas ( -- m ) dct-matrix >float-blas-matrix ;
: V.M ( x A -- x.A ) Mtranspose swap M.V ;
: idct-blas ( b -- b' ) >float-blas-vector dct-matrix-blas V.M ;

: idct ( b -- b' ) idct-blas ;

:: draw-block ( block x,y color-id jpeg-image -- )
    block dup length>> sqrt >fixnum group flip
    dup matrix-dim coord-matrix flip
    [
        [ first2 spin nth nth ]
        [ x,y v+ color-id jpeg-image draw-color ] bi
    ] with each^2 ;

: sign-extend ( bits v -- v' )
    swap [ ] [ 1 - 2^ < ] 2bi
    [ -1 swap shift 1 + + ] [ drop ] if ;

: read1-jpeg-dc ( decoder -- dc )
    [ read1-huff dup ] [ bs>> bs:read ] bi sign-extend ;

: read1-jpeg-ac ( decoder -- run/ac )
    [ read1-huff 16 /mod dup ] [ bs>> bs:read ] bi sign-extend 2array ;

:: decode-block ( color -- pixels )
    color dc-huff-table>> read1-jpeg-dc color apply-diff
    64 0 <array> :> coefs
    0 coefs set-nth
    0 :> k!
    [
        color ac-huff-table>> read1-jpeg-ac
        [ first 1 + k + k! ] [ second k coefs set-nth ] [ ] tri
        { 0 0 } = not
        k 63 < and
    ] loop
    coefs color quant-table>> v*
    reverse-zigzag idct ;
    
:: draw-macroblock-yuv420 ( mb blocks -- )
    mb { 16 16 } v* :> pos
    0 blocks nth pos { 0 0 } v+ 0 jpeg> draw-block
    1 blocks nth pos { 8 0 } v+ 0 jpeg> draw-block
    2 blocks nth pos { 0 8 } v+ 0 jpeg> draw-block
    3 blocks nth pos { 8 8 } v+ 0 jpeg> draw-block
    4 blocks nth 8 group 2 matrix-zoom concat pos 1 jpeg> draw-block
    5 blocks nth 8 group 2 matrix-zoom concat pos 2 jpeg> draw-block ;
    
:: draw-macroblock-yuv444 ( mb blocks -- )
    mb { 8 8 } v* :> pos
    3 iota [ [ blocks nth pos ] [ jpeg> draw-block ] bi ] each ;

:: draw-macroblock-y ( mb blocks -- )
    mb { 8 8 } v* :> pos
    0 blocks nth pos 0 jpeg> draw-block
    64 0 <array> pos 1 jpeg> draw-block
    64 0 <array> pos 2 jpeg> draw-block ;
 
    ! %fixme: color hack
 !   color h>> 2 =
 !   [ 8 group 2 matrix-zoom concat ] unless
 !   pos { 8 8 } v* color jpeg> draw-block ;

: decode-macroblock ( -- blocks )
    jpeg> components>>
    [
        [ mb-dim first2 * iota ]
        [ [ decode-block ] curry replicate ] bi
    ] map concat ;

: cleanup-bitstream ( bytes -- bytes' )
    binary [
        [
            { HEX: FF } read-until
            read1 tuck HEX: 00 = and
        ]
        [ drop ] produce
        swap >marker {  EOI } assert=
        swap suffix
        { HEX: FF } join
    ] with-byte-reader ;

: setup-bitmap ( image -- )
    dup dim>> 16 v/n [ ceiling ] map 16 v*n >>dim
    BGR >>component-order
    ubyte-components >>component-type
    f >>upside-down?
    dup dim>> first2 * 3 * 0 <array> >>bitmap
    drop ;

ERROR: unsupported-colorspace ;
SINGLETONS: YUV420 YUV444 Y MAGIC! ;

:: detect-colorspace ( jpeg-image -- csp )
    jpeg-image color-info>> sift :> colors
    MAGIC!
    colors length 1 = [ drop Y ] when
    colors length 3 =
    [
        colors [ mb-dim { 1 1 } = ] all?
        [ drop YUV444 ] when

        colors unclip
        [ [ mb-dim { 1 1 } = ] all? ]
        [ mb-dim { 2 2 } =  ] bi* and
        [ drop YUV420 ] when
    ] when ;
    
! this eats ~50% cpu time
: draw-macroblocks ( mbs -- )
    jpeg> detect-colorspace
    {
        { YUV420 [ [ first2 draw-macroblock-yuv420 ] each ] }
        { YUV444 [ [ first2 draw-macroblock-yuv444 ] each ] }
        { Y      [ [ first2 draw-macroblock-y ] each ] }
        [ unsupported-colorspace ]
    } case ;

! this eats ~25% cpu time
: color-transform ( yuv -- rgb )
    { 128 0 0 } v+ yuv>bgr-matrix swap m.v
    [ 0 max 255 min >fixnum ] map ;

: baseline-decompress ( -- )
    jpeg> bitstream>> cleanup-bitstream { 255 255 255 255 } append
    >byte-array bs:<msb0-bit-reader> jpeg> (>>bitstream)
    jpeg> 
    [ bitstream>> ] 
    [ [ [ <huffman-decoder> ] with map ] change-huff-tables drop ] bi
    jpeg> components>> [ fetch-tables ] each
    [ decode-macroblock 2array ] accumulator 
    [ all-macroblocks ] dip
    jpeg> setup-bitmap draw-macroblocks 
    jpeg> bitmap>> 3 <groups> [ color-transform ] change-each
    jpeg> [ >byte-array ] change-bitmap drop ;

ERROR: not-a-jpeg-image ;

PRIVATE>

M: jpeg-image stream>image ( stream jpeg-image -- bitmap )
    drop [
        parse-marker { SOI } = [ not-a-jpeg-image ] unless
        parse-headers
        contents <jpeg-image>
    ] with-input-stream
    dup jpeg-image [
        baseline-parse
        baseline-decompress
    ] with-variable ;
