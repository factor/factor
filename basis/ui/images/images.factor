! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache formatting images images.loader
kernel math namespaces opengl opengl.textures sequences
splitting ui.gadgets.worlds ui.render ;
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

! GL3 image drawing (creates texture, draws, deletes)
:: draw-image-gl3 ( image -- )
    image cached-image :> img
    img make-texture-gl3 :> tex-id
    { 0 0 } img dim>> [ gl-unscale ] map tex-id img upside-down?>> gl3-draw-texture
    tex-id delete-texture ;

:: draw-scaled-image-gl3 ( dim image -- )
    image cached-image :> img
    img make-texture-gl3 :> tex-id
    { 0 0 } dim tex-id img upside-down?>> gl3-draw-texture
    tex-id delete-texture ;

: draw-image ( image -- )
    gl3-mode? get-global
    [ draw-image-gl3 ]
    [ rendered-image draw-texture ] if ;

: draw-scaled-image ( dim image -- )
    gl3-mode? get-global
    [ draw-scaled-image-gl3 ]
    [ rendered-image draw-scaled-texture ] if ;

: image-dim ( image -- dim )
    cached-image dim>> [ gl-unscale ] map ;
