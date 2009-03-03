! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors grouping sequences combinators
math specialized-arrays.direct.uint byte-arrays
specialized-arrays.direct.ushort specialized-arrays.uint
specialized-arrays.ushort specialized-arrays.float ;
IN: images

SINGLETONS: BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
R16G16B16 R32G32B32 R16G16B16A16 R32G32B32A32 ;

: bytes-per-pixel ( component-order -- n )
    {
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

TUPLE: image dim component-order bitmap ;

: <image> ( -- image ) image new ; inline

GENERIC: load-image* ( path tuple -- image )

: add-dummy-alpha ( seq -- seq' )
    3 <sliced-groups>
    [ 255 suffix ] map concat ;

: normalize-floats ( byte-array -- byte-array )
    byte-array>float-array [ 255.0 * >integer ] B{ } map-as ;

: normalize-component-order ( image -- image )
    dup component-order>>
    {
        { RGBA [ ] }
        { R32G32B32A32 [
            [ normalize-floats ] change-bitmap
        ] }
        { R32G32B32 [
            [ normalize-floats add-dummy-alpha ] change-bitmap
        ] }
        { R16G16B16A16 [
            [ byte-array>ushort-array [ -8 shift ] B{ } map-as ] change-bitmap
        ] }
        { R16G16B16 [
            [
                byte-array>ushort-array [ -8 shift ] B{ } map-as add-dummy-alpha
            ] change-bitmap
        ] }
        { BGRA [
            [
                4 <sliced-groups> dup [ 3 head-slice reverse-here ] each
            ] change-bitmap
        ] }
        { RGB [ [ add-dummy-alpha ] change-bitmap ] }
        { BGR [
            [
                3 <sliced-groups>
                [ [ 3 head-slice reverse-here ] each ]
                [ [ 255 suffix ] map ] bi concat
            ] change-bitmap
        ] }
    } case
    RGBA >>component-order ;

GENERIC: normalize-scan-line-order ( image -- image )

M: image normalize-scan-line-order ;

: normalize-image ( image -- image )
    [ >byte-array ] change-bitmap
    normalize-component-order
    normalize-scan-line-order ;
