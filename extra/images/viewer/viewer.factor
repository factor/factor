! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images images.loader io.pathnames kernel namespaces
opengl opengl.gl opengl.textures sequences strings ui ui.gadgets
ui.gadgets.panes ui.render ui.images ;
IN: images.viewer

TUPLE: image-gadget < gadget image-name ;

M: image-gadget pref-dim*
    image-name>> image-dim ;

M: image-gadget draw-gadget* ( gadget -- )
    image-name>> draw-image ;

: <image-gadget> ( image-name -- gadget )
    \ image-gadget new
        swap >>image-name ;

: image-window ( path -- gadget )
    [ <image-name> <image-gadget> dup ] [ open-window ] bi ;

GENERIC: image. ( object -- )

M: string image. ( image -- ) <image-name> <image-gadget> gadget. ;

M: pathname image. ( image -- ) <image-name> <image-gadget> gadget. ;
