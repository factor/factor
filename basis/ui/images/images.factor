! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces cache images images.loader accessors assocs kernel
opengl opengl.gl opengl.textures opengl.texture-cache ui.gadgets.worlds ;
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

SINGLETON: image-renderer

M: image-renderer render-texture
    drop cached-image ;

SLOT: images

: image-texture-cache ( world -- texture-cache )
    [ [ image-renderer <texture-cache> ] unless* ] change-images
    images>> ;

PRIVATE>

: rendered-image ( path -- texture )
    world get image-texture-cache get-texture ;

: draw-image ( image-name -- )
    rendered-image display-list>> glCallList ;

: draw-scaled-image ( dim image-name -- )
    rendered-image texture>> draw-textured-rect ;

: image-dim ( image-name -- dim )
    cached-image dim>> ;