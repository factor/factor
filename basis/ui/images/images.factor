! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache combinators images.loader kernel
memoize namespaces opengl.textures system ui.gadgets.worlds
vocabs ;
IN: ui.images

TUPLE: image-name path ;

C: <image-name> image-name

MEMO: cached-image ( image-name -- image ) path>> load-image ;

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
    cached-image dim>> ;

{
    { [ os macosx? ] [ "images.loader.cocoa" require ] }
    { [ os windows?  ] [ "images.loader.gdiplus" require ] }
    [ "images.loader.gtk" require ]
} cond
