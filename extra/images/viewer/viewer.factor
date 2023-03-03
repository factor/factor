! Copyright (C) 2007, 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.short-circuit continuations
destructors images images.loader io.pathnames kernel math
models opengl.gl opengl.textures opengl.textures.private
sequences strings ui ui.gadgets ui.gadgets.panes
ui.gadgets.worlds ui.render ;
IN: images.viewer

TUPLE: image-gadget < gadget image texture ;
<PRIVATE
M: image-gadget pref-dim* image>> [ image-dim ] [ { 640 480 } ] if* ;

: (image-gadget-texture) ( gadget -- texture )
    dup image>> { 0 0 } <texture> >>texture texture>> ;
: image-gadget-texture ( gadget -- texture )
    [ texture>> ] [ (image-gadget-texture) ] ?unless ;

M: image-gadget draw-gadget* ( gadget -- )
    dup image>> [
        [ dim>> ] [ image-gadget-texture ] bi draw-scaled-texture
    ] [
        drop
    ] if ;

: delete-current-texture ( image-gadget -- )
    [ texture>> [ dispose ] when* ]
    [ f >>texture drop ] bi ;

! In unit tests, find-gl-context throws no-world-found when using with-grafted-gadget.
M: image-gadget ungraft* [ dup find-gl-context delete-current-texture ] [ 2drop ] recover ;
PRIVATE>
TUPLE: image-control < image-gadget image-updated? ;
<PRIVATE

: (bind-2d-texture) ( texture-id -- )
    [ GL_TEXTURE_2D ] dip glBindTexture ;
: bind-2d-texture ( single-texture -- )
    texture>> (bind-2d-texture) ;
: (update-texture) ( image single-texture -- )
    bind-2d-texture tex-sub-image ;
! works only for single-texture
: update-texture ( image-gadget -- )
    [ image>> ] [ texture>> ] bi
    (update-texture) ;
GENERIC: texture-size ( texture -- dim )
M: single-texture texture-size dim>> ;

:: grid-width ( grid element-quot -- width )
    grid [ 0 ] [
        first element-quot [ + ] map-reduce
    ] if-empty ; inline
: grid-dim ( grid -- dim )
    [ [ dim>> first ] grid-width ] [ flip [ dim>> second ] grid-width ] bi 2array ;
M: multi-texture texture-size
    grid>> grid-dim ;
: same-size? ( image-gadget -- ? )
    [ texture>> texture-size ] [ image>> dim>> ] bi = ;
: (texture-format) ( texture-id -- format )
    (bind-2d-texture) GL_TEXTURE_2D 0
    GL_TEXTURE_INTERNAL_FORMAT get-texture-int ;
! works only for single-texture
: texture-format ( image-gadget -- format/f )
    texture>> [
        texture>> [
            (texture-format)
        ] [ f ] if*
    ] [ f ] if* ;
: same-internal-format? ( image-gadget -- ? )
    [ texture-format ] [ image>> image-format 2drop ] bi = ;

! TODO: also keep multitextures if possible ?
: keep-same-texture? ( image-gadget -- ? )
    { [ texture>> single-texture? ]
      [ same-size? ]
      [ same-internal-format? ] } 1&& ;
: ?update-texture ( image-gadget -- )
    dup image-updated?>> [
        f >>image-updated?
        dup keep-same-texture? [ update-texture ] [ delete-current-texture ] if
    ] [ drop ] if ;

M: image-control model-changed
    swap value>> >>image t >>image-updated? relayout ;
M: image-control draw-gadget* [ ?update-texture ] [ call-next-method ] bi ;
PRIVATE>
GENERIC: set-image ( gadget object -- gadget )
M: image set-image >>image ;
M: string set-image load-image >>image ;
M: pathname set-image string>> load-image >>image ;
M: model set-image [ value>> >>image drop ] [ >>model ] 2bi ;
: new-image-gadget ( class -- gadget ) new ;
: new-image-gadget* ( object class -- gadget )
    new-image-gadget swap set-image ;
: <image-gadget> ( object -- gadget )
    \ image-gadget new-image-gadget* ;
: <image-control> ( model -- gadget )
    \ image-control new-image-gadget* ;
: image-window ( object -- ) <image-gadget> "Image" open-window ;

: image. ( object -- ) <image-gadget> gadget. ;

M: image content-gadget
    <image-gadget> ;
