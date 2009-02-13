! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors grouping sequences combinators
math specialized-arrays.direct.uint byte-arrays ;
IN: images

SINGLETONS: BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR
32R32G32B ;

TUPLE: image dim component-order byte-order bitmap ;

: <image> ( -- image ) image new ; inline

GENERIC: load-image* ( path tuple -- image )

: normalize-component-order ( image -- image )
    dup component-order>>
    {
        { RGBA [ ] }
        { 32R32G32B [
            [
                ! >byte-array
                ! dup length 4 /i <direct-uint-array> [ 32 2^ /i ] map
                ! >byte-array
                ! 4 <sliced-groups> le> [ 32 2^ /i ] map concat
            ] change-bitmap
        ] }
        { BGRA [
            [
                4 <sliced-groups> dup [ [ 0 3 ] dip <slice> reverse-here ] each
            ] change-bitmap
        ] }
        { RGB [
            [ 3 <sliced-groups> [ 255 suffix ] map concat ] change-bitmap
        ] }
        { BGR [
            [
                3 <sliced-groups> dup [ [ 0 3 ] dip <slice> reverse-here ] each
                [ 255 suffix ] map concat
            ] change-bitmap
        ] }
    } case
    RGBA >>component-order ;

GENERIC: normalize-scan-line-order ( image -- image )

M: image normalize-scan-line-order ;

: normalize-image ( image -- image )
    normalize-component-order
    normalize-scan-line-order ;
