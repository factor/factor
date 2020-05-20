! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache combinators images.loader kernel
math memoize namespaces opengl opengl.textures sequences
splitting system ui.gadgets.worlds vocabs ;
IN: ui.images

TUPLE: image-name path ;

C: <image-name> image-name

<PRIVATE

MEMO: cached-image-path ( path -- image )
    [ load-image ] [ "@2x" swap subseq? >>2x? ] bi ;

PRIVATE>

: cached-image ( image-name -- image )
    path>> gl-scale-factor get-global 1.0 > [
        "." split1-last "@2x." glue
    ] when cached-image-path ;

<PRIVATE

: image-texture-cache ( world -- texture-cache )
    [ [ <cache-assoc> ] unless* ] change-images images>> ;

PRIVATE>

: rendered-image ( image-name -- texture )
    world get image-texture-cache
    [ cached-image { 0 0 } <texture> ] cache ;

: draw-image ( image-name -- )
    rendered-image draw-texture ;

: draw-scaled-image ( dim image-name -- )
    rendered-image draw-scaled-texture ;

: image-dim ( image-name -- dim )
    cached-image [ dim>> ] [ 2x?>> [ [ 2 / ] map ] when ] bi ;

{
    { [ os macosx? ] [ "images.loader.cocoa" require ] }
    { [ os windows?  ] [ "images.loader.gdiplus" require ] }
    { [ os { freebsd } member? ] [
        "images.png" require
        "images.tiff" require
    ] }
    [ "images.loader.gtk" require ]
} cond
