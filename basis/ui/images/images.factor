! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache formatting images images.loader
kernel math namespaces opengl opengl.textures sequences
splitting ui.gadgets.worlds ;
IN: ui.images

TUPLE: image-name path ;

C: <image-name> image-name

<PRIVATE

MEMO: (cached-image) ( path -- image ) load-image ;

PRIVATE>

GENERIC: cached-image ( image -- image )

M: image-name cached-image
    path>> gl-scale-factor get-global [
        dup 2.0 < [ drop ] [
            [ "." split1-last ] [ "@%dx." sprintf glue ] bi*
        ] if
    ] when* (cached-image) ;

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
    cached-image dim>> gl-scale-factor get-global [ '[ _ /i ] map ] when* ;
