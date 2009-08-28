! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images images.loader io.pathnames kernel
models namespaces opengl opengl.gl opengl.textures sequences
strings ui ui.gadgets ui.gadgets.panes ui.images ui.render
constructors ;
IN: images.viewer

TUPLE: image-gadget < gadget image texture ;

M: image-gadget pref-dim* image>> dim>> ;

: image-gadget-texture ( gadget -- texture )
    dup texture>> [ ] [ dup image>> { 0 0 } <texture> >>texture texture>> ] ?if ;

M: image-gadget draw-gadget* ( gadget -- )
    dup image>> [
        [ dim>> ] [ image-gadget-texture ] bi draw-scaled-texture
    ] [
        drop
    ] if ;

TUPLE: image-control < image-gadget ;

CONSTRUCTOR: image-control ( model -- image-control ) ;

M: image-control pref-dim* image>> [ dim>> ] [ { 640 480 } ] if* ;

M: image-control model-changed
    swap value>> >>image relayout ;

! Todo: delete texture on ungraft

GENERIC: <image-gadget> ( object -- gadget )

M: image <image-gadget>
    \ image-gadget new
        swap >>image ;

M: string <image-gadget> load-image <image-gadget> ;

M: pathname <image-gadget> string>> load-image <image-gadget> ;

: image-window ( object -- ) <image-gadget> "Image" open-window ;

: image. ( object -- ) <image-gadget> gadget. ;
