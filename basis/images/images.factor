! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel accessors sequences math ;
IN: images

SINGLETONS: L LA BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
R16G16B16 R32G32B32 R16G16B16A16 R32G32B32A32 ;

UNION: alpha-channel BGRA RGBA ABGR ARGB R16G16B16A16 R32G32B32A32 ;

: bytes-per-pixel ( component-order -- n )
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
        { R16G16B16 [ 6 ] }
        { R32G32B32 [ 12 ] }
        { R16G16B16A16 [ 8 ] }
        { R32G32B32A32 [ 16 ] }
    } case ;

TUPLE: image dim component-order upside-down? bitmap ;

: <image> ( -- image ) image new ; inline

: has-alpha? ( image -- ? ) component-order>> alpha-channel? ;

GENERIC: load-image* ( path tuple -- image )

<PRIVATE

: pixel@ ( x y image -- start end bitmap )
    [ dim>> second * + ]
    [ component-order>> bytes-per-pixel [ * dup ] keep + ]
    [ bitmap>> ] tri ;

: set-subseq ( new-value from to victim -- )
    <slice> 0 swap copy ; inline

PRIVATE>

: pixel-at ( x y image -- pixel )
    pixel@ subseq ;

: set-pixel-at ( pixel x y image -- )
    pixel@ set-subseq ;
