! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel accessors sequences math arrays ;
IN: images

SINGLETONS:
    L LA BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
    ubyte-components ushort-components
    half-components float-components
    byte-integer-components ubyte-integer-components
    short-integer-components ushort-integer-components
    int-integer-components uint-integer-components ;

UNION: component-order 
    L LA BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR ;

UNION: component-type
    ubyte-components ushort-components
    half-components float-components
    byte-integer-components ubyte-integer-components
    short-integer-components ushort-integer-components
    int-integer-components uint-integer-components ;

UNION: unnormalized-integer-components
    byte-integer-components ubyte-integer-components
    short-integer-components ushort-integer-components
    int-integer-components uint-integer-components ;

UNION: alpha-channel BGRA RGBA ABGR ARGB ;

TUPLE: image dim component-order component-type upside-down? bitmap ;

: <image> ( -- image ) image new ; inline

: has-alpha? ( image -- ? ) component-order>> alpha-channel? ;

GENERIC: load-image* ( path class -- image )

DEFER: bytes-per-pixel

<PRIVATE

: bytes-per-component ( component-type -- n )
    {
        { ubyte-components [ 1 ] }
        { ushort-components [ 2 ] }
        { half-components [ 2 ] }
        { float-components [ 4 ] }
        { byte-integer-components [ 1 ] }
        { ubyte-integer-components [ 1 ] }
        { short-integer-components [ 2 ] }
        { ushort-integer-components [ 2 ] }
        { int-integer-components [ 4 ] }
        { uint-integer-components [ 4 ] }
    } case ;

: component-count ( component-order -- n )
    {
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
    } case ;

: pixel@ ( x y image -- start end bitmap )
    [ dim>> first * + ]
    [ bytes-per-pixel [ * dup ] keep + ]
    [ bitmap>> ] tri ;

: set-subseq ( new-value from to victim -- )
    <slice> 0 swap copy ; inline

PRIVATE>

: bytes-per-pixel ( image -- n )
    [ component-order>> component-count ]
    [ component-type>>  bytes-per-component ] bi * ;

: pixel-at ( x y image -- pixel )
    pixel@ subseq ;

: set-pixel-at ( pixel x y image -- )
    pixel@ set-subseq ;
