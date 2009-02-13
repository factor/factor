! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors grouping sequences combinators
math specialized-arrays.direct.uint byte-arrays ;
IN: images

SINGLETONS: BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
R16G16B16 R32G32B32 ;

TUPLE: image dim component-order bitmap ;

: <image> ( -- image ) image new ; inline

GENERIC: load-image* ( path tuple -- image )

: add-dummy-alpha ( seq -- seq' )
    3 <sliced-groups>
    [ 255 suffix ] map concat ;

: normalize-component-order ( image -- image )
    dup component-order>>
    {
        { RGBA [ ] }
        { R32G32B32 [
            [
                dup length 4 / <direct-uint-array>
                [ bits>float 255.0 * >integer ] map
                >byte-array add-dummy-alpha
            ] change-bitmap
        ] }
        { BGRA [
            [
                4 <sliced-groups> dup [ [ 0 3 ] dip <slice> reverse-here ] each
            ] change-bitmap
        ] }
        { RGB [ [ add-dummy-alpha ] change-bitmap ] }
        { BGR [
            [
                3 <sliced-groups>
                [ [ [ 0 3 ] dip <slice> reverse-here ] each ]
                [ add-dummy-alpha ] bi
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
