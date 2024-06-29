! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache combinators images images.loader
kernel math namespaces opengl opengl.textures sequences
splitting system ui.gadgets.worlds vocabs ;
IN: ui.images

TUPLE: image-name path ;

C: <image-name> image-name

<PRIVATE

MEMO: cached-image-path ( path -- image )
    [ load-image ] [ "@2x" subseq-of? >>2x? ] bi ;

PRIVATE>

GENERIC: cached-image ( image -- image )

M: image-name cached-image
    path>> gl-scale-factor get-global [ 1.0 > ] [ f ] if* [
        "." split1-last "@2x." glue
    ] when cached-image-path ;

M: image cached-image ;

<PRIVATE

: image-texture-cache ( world -- texture-cache )
    [ [ <cache-assoc> ] unless* ] change-images images>> ;

PRIVATE>

: rendered-image ( image -- texture )
    world get image-texture-cache
    [ cached-image { 0 0 } <texture> ] cache ;

: draw-image ( image -- )
    rendered-image draw-texture ;

: draw-scaled-image ( dim image -- )
    rendered-image draw-scaled-texture ;

: image-dim ( image -- dim )
    cached-image [ dim>> ] [ 2x?>> [ [ 2 / ] map ] when ] bi ;

{
    { [ os macos? ] [ "images.loader.cocoa" require ] }
    { [ os windows?  ] [ "images.loader.gdiplus" require ] }
    { [ os { freebsd } member? ] [
        "images.png" require
        "images.tiff" require
    ] }
    [ "images.loader.gtk" require ]
} cond
