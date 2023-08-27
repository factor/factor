! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences ;
IN: images

SINGLETONS:
    A L LA BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
    INTENSITY DEPTH DEPTH-STENCIL R RG
    ubyte-components ushort-components uint-components
    half-components float-components
    byte-integer-components ubyte-integer-components
    short-integer-components ushort-integer-components
    int-integer-components uint-integer-components
    u-5-5-5-1-components u-5-6-5-components
    u-10-10-10-2-components
    u-24-components u-24-8-components
    float-32-u-8-components
    u-9-9-9-e5-components
    float-11-11-10-components ;

UNION: component-order
    A L LA BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
    INTENSITY DEPTH DEPTH-STENCIL R RG ;

UNION: component-type
    ubyte-components ushort-components uint-components
    half-components float-components
    byte-integer-components ubyte-integer-components
    short-integer-components ushort-integer-components
    int-integer-components uint-integer-components
    u-5-5-5-1-components u-5-6-5-components
    u-10-10-10-2-components
    u-24-components u-24-8-components
    float-32-u-8-components
    u-9-9-9-e5-components
    float-11-11-10-components ;

UNION: unnormalized-integer-components
    byte-integer-components ubyte-integer-components
    short-integer-components ushort-integer-components
    int-integer-components uint-integer-components ;

UNION: signed-unnormalized-integer-components
    byte-integer-components
    short-integer-components
    int-integer-components ;

UNION: unsigned-unnormalized-integer-components
    ubyte-integer-components
    ushort-integer-components
    uint-integer-components ;

UNION: packed-components
    u-5-5-5-1-components u-5-6-5-components
    u-10-10-10-2-components
    u-24-components u-24-8-components
    float-32-u-8-components
    u-9-9-9-e5-components
    float-11-11-10-components ;

UNION: alpha-channel BGRA RGBA ABGR ARGB LA A INTENSITY ;

UNION: alpha-channel-precedes-colors ABGR ARGB XBGR XRGB ;

TUPLE: image
    dim component-order component-type
    upside-down? premultiplied-alpha?
    bitmap 2x? ;

: <image> ( -- image ) image new ; inline

: image-dim ( image -- dim )
    [ dim>> ] [ 2x?>> ] bi [ [ 2.0 / ] map ] when ;

: has-alpha? ( image -- ? ) component-order>> alpha-channel? ;

: bytes-per-component ( component-type -- n )
    {
        { ubyte-components [ 1 ] }
        { ushort-components [ 2 ] }
        { uint-components [ 4 ] }
        { half-components [ 2 ] }
        { float-components [ 4 ] }
        { byte-integer-components [ 1 ] }
        { ubyte-integer-components [ 1 ] }
        { short-integer-components [ 2 ] }
        { ushort-integer-components [ 2 ] }
        { int-integer-components [ 4 ] }
        { uint-integer-components [ 4 ] }
    } case ;

: bytes-per-packed-pixel ( component-type -- n )
    {
        { u-5-5-5-1-components [ 2 ] }
        { u-5-6-5-components [ 2 ] }
        { u-10-10-10-2-components [ 4 ] }
        { u-24-components [ 4 ] }
        { u-24-8-components [ 4 ] }
        { u-9-9-9-e5-components [ 4 ] }
        { float-11-11-10-components [ 4 ] }
        { float-32-u-8-components [ 8 ] }
    } case ;

: component-count ( component-order -- n )
    {
        { A [ 1 ] }
        { L [ 1 ] }
        { LA [ 2 ] }
        { BGR [ 3 ] }
        { RGB [ 3 ] }
        { BGRA [ 4 ] }
        { RGBA [ 4 ] }
        { ABGR [ 4 ] }
        { ARGB [ 4 ] }
        { RGBX [ 4 ] }
        { XRGB [ 4 ] }
        { BGRX [ 4 ] }
        { XBGR [ 4 ] }
        { INTENSITY [ 1 ] }
        { DEPTH [ 1 ] }
        { DEPTH-STENCIL [ 1 ] }
        { R [ 1 ] }
        { RG [ 2 ] }
    } case ;

: (bytes-per-pixel) ( component-order component-type -- n )
    dup packed-components?
    [ nip bytes-per-packed-pixel ] [
        [ component-count ] [ bytes-per-component ] bi* *
    ] if ;

: bytes-per-pixel ( image -- n )
    [ component-order>> ] [ component-type>> ] bi (bytes-per-pixel) ;

: bytes-per-image ( image -- n )
    [ dim>> product ] [ bytes-per-pixel ] bi * ;

: rowstride ( image -- n )
    [ dim>> first ] [ bytes-per-pixel ] bi * ;

<PRIVATE

:: pixel@ ( x y w image -- start end bitmap )
    image dim>> first y * x + :> start
    start w [ image bytes-per-pixel * ] bi@ :> ( start' w' )
    start'  start' w' +  image bitmap>> ; inline

: set-subseq ( new-value from to victim -- )
    <slice> 0 swap copy ; inline

PRIVATE>

: pixel-row-at ( x y w image -- pixels )
    pixel@ subseq ; inline

: pixel-row-slice-at ( x y w image -- pixels )
    pixel@ <slice> ; inline

: set-pixel-row-at ( pixel x y w image -- )
    pixel@ set-subseq ; inline

: pixel-at ( x y image -- pixel )
    [ 1 ] dip pixel-row-at ; inline

: pixel-slice-at ( x y image -- pixels )
    [ 1 ] dip pixel-row-slice-at ; inline

: set-pixel-at ( pixel x y image -- )
    [ 1 ] dip set-pixel-row-at ; inline

:: each-pixel ( ... image quot: ( ... x y pixel -- ... ) -- ... )
    image dim>> first2 :> ( width height )
    image bytes-per-pixel :> n
    height width [ <iota> ] bi@ [| y x |
        y width * x + :> start
        start n * :> from
        from n + :> to
        x y from to image bitmap>> <slice> quot call
    ] cartesian-each ; inline
