! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces cache images images.loader accessors assocs
kernel opengl opengl.gl opengl.textures ui.gadgets.worlds ;
IN: ui.images

TUPLE: image-name path ;

C: <image-name> image-name

<PRIVATE

SYMBOL: image-cache

image-cache [ <cache-assoc> ] initialize

PRIVATE>

: cached-image ( image-name -- image )
    path>> image-cache get [ load-image ] cache ;

<PRIVATE

SLOT: images

: image-texture-cache ( world -- texture-cache )
    [ [ <cache-assoc> ] unless* ] change-images images>> ;

PRIVATE>

: rendered-image ( path -- texture )
    world get image-texture-cache [ cached-image <texture> ] cache ;

: draw-image ( image-name -- )
    rendered-image display-list>> glCallList ;

: draw-scaled-image ( dim image-name -- )
    rendered-image texture>> draw-textured-rect ;

: image-dim ( image-name -- dim )
    cached-image dim>> ;