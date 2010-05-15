! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images images.loader io.pathnames kernel
models namespaces opengl opengl.gl opengl.textures sequences
strings ui ui.gadgets ui.gadgets.panes ui.images ui.render
constructors locals combinators.short-circuit 
literals ;
FROM: gpu.textures.private => get-texture-int ;
IN: images.viewer

TUPLE: image-gadget < gadget image texture ;
<PRIVATE
M: image-gadget pref-dim* image>> dim>> ;

: (image-gadget-texture) ( gadget -- texture )
    dup image>> { 0 0 } <texture> >>texture texture>> ;
: image-gadget-texture ( gadget -- texture )
    dup texture>> [ ] [ (image-gadget-texture) ] ?if ;

M: image-gadget draw-gadget* ( gadget -- )
    dup image>> [
        [ dim>> ] [ image-gadget-texture ] bi draw-scaled-texture
    ] [
        drop
    ] if ;

: delete-current-texture ( image-gadget -- )
    [ texture>> [ texture>> [ delete-texture ] when* ] when* ]
    [ f >>texture drop ] bi ;

M: image-gadget ungraft* delete-current-texture ;
PRIVATE>
TUPLE: image-control < image-gadget image-updated? ;
<PRIVATE

: (bind-2d-texture) ( texture-id -- )
    [ GL_TEXTURE_2D ] dip glBindTexture ;
: bind-2d-texture ( texture -- )
    texture>> (bind-2d-texture) ;
: (update-texture) ( image texture -- ) 
    bind-2d-texture
    [ GL_TEXTURE_2D 0 0 0 ] dip
    [ dim>> first2 ]
    [ [ component-order>> ] [ component-type>> ] bi image-data-format ]
    [ bitmap>> ] tri
    glTexSubImage2D ;
: update-texture ( image-gadget -- )
    [ image>> ] [ texture>> ] bi
    (update-texture) ;
: (texture-size) ( texture-id -- size )
    (bind-2d-texture) GL_TEXTURE_2D 0 
    ${ GL_TEXTURE_WIDTH GL_TEXTURE_HEIGHT } [ get-texture-int ] with with map ;
: texture-size ( image-gadget -- size/f )
    texture>> [
        texture>> [
            (texture-size)
        ] [ { 0 0 } ] if*
    ] [ f ] if* ;
: same-size? ( image-gadget -- ? )
    [ texture-size ] [ image>> dim>> ] bi = ;
: (texture-format) ( texture-id -- format )
    (bind-2d-texture) GL_TEXTURE_2D 0
    GL_TEXTURE_INTERNAL_FORMAT get-texture-int ;
: texture-format ( image-gadget -- format/f )
    texture>> [
        texture>> [
            (texture-format)
        ] [ f ] if*
    ] [ f ] if* ;
: same-internal-format? ( image-gadget -- ? ) 
   [ texture-format ] [ image>> image-format 2drop ] bi = ;
: keep-same-texture? ( image-gadget -- ? )
    { [ same-size? ] [ same-internal-format? ] } 1&& ;
: ?update-texture ( image-gadget -- )
    dup image-updated?>> [
        f >>image-updated?
        dup keep-same-texture? [ update-texture ] [ delete-current-texture ] if
    ] [ drop ] if ;

M: image-control pref-dim* image>> [ dim>> ] [ { 640 480 } ] if* ;
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

! move these words to ui.gadgets because they affect all controls ?
: stop-control ( gadget -- ) dup model>> [ remove-connection ] [ drop ] if* ;
: start-control ( gadget -- ) dup model>> [ add-connection ] [ drop ] if* ;

: image. ( object -- ) <image-gadget> gadget. ;

<PRIVATE
M: image-control graft* start-control ;
M: image-control ungraft* [ stop-control ] [ call-next-method ] bi ;
PRIVATE>
