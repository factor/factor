! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel ;
IN: images

SINGLETONS: L BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
R16G16B16 R32G32B32 R16G16B16A16 R32G32B32A32 ;

: bytes-per-pixel ( component-order -- n )
    {
        { L [ 1 ] }
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

GENERIC: load-image* ( path tuple -- image )