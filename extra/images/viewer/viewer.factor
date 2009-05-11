! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images images.loader io.pathnames kernel namespaces
opengl opengl.gl opengl.textures sequences strings ui ui.gadgets
ui.gadgets.panes ui.render ui.images ;
IN: images.viewer

TUPLE: image-gadget < gadget image texture ;

M: image-gadget pref-dim* image>> dim>> ;

: image-gadget-texture ( gadget -- texture )
    dup texture>> [ ] [ dup image>> { 0 0 } <texture> >>texture texture>> ] ?if ;

M: image-gadget draw-gadget* ( gadget -- )
    [ dim>> ] [ image-gadget-texture ] bi draw-scaled-texture ;

! Todo: delete texture on ungraft

GENERIC: <image-gadget> ( object -- gadget )

M: image <image-gadget>
    \ image-gadget new
        swap >>image ;

M: string <image-gadget> load-image <image-gadget> ;

M: pathname <image-gadget> string>> load-image <image-gadget> ;

: image-window ( object -- ) <image-gadget> "Image" open-window ;

: image. ( object -- ) <image-gadget> gadget. ;
