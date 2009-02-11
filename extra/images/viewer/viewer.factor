! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images images.backend io.pathnames kernel
namespaces opengl opengl.gl sequences strings ui ui.gadgets
ui.gadgets.panes ui.render ;
IN: images.viewer

TUPLE: image-gadget < gadget { image image } ;

M: image-gadget pref-dim*
    image>> dim>> ;

: draw-image ( tiff -- )
    0 0 glRasterPos2i 1.0 -1.0 glPixelZoom
    [ dim>> first2 GL_RGBA GL_UNSIGNED_BYTE ]
    [ bitmap>> ] bi glDrawPixels ;

M: image-gadget draw-gadget* ( gadget -- )
    origin get [ image>> draw-image ] with-translation ;

: <image-gadget> ( image -- gadget )
    \ image-gadget new-gadget
        swap >>image ;

: image-window ( path -- gadget )
    [ <image> <image-gadget> dup ] [ open-window ] bi ;

GENERIC: image. ( object -- )

: default-image. ( path -- )
    <image-gadget> gadget. ;

M: string image. ( image -- ) <image> default-image. ;

M: pathname image. ( image -- ) <image> default-image. ;

M: image image. ( image -- ) default-image. ;
