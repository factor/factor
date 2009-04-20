! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images images.loader io.pathnames kernel namespaces
opengl opengl.gl opengl.textures sequences strings ui ui.gadgets
ui.gadgets.panes ui.render ;
IN: images.viewer

TUPLE: image-gadget < gadget { image image } ;

M: image-gadget pref-dim*
    image>> dim>> ;

: draw-image ( image -- )
    0 0 glRasterPos2i 1.0 -1.0 glPixelZoom
    [ dim>> first2 ] [ component-order>> component-order>format ] [ bitmap>> ] tri
    glDrawPixels ;

M: image-gadget draw-gadget* ( gadget -- )
    image>> draw-image ;

: <image-gadget> ( image -- gadget )
    \ image-gadget new
        swap >>image ;

: image-window ( path -- gadget )
    [ load-image <image-gadget> dup ] [ open-window ] bi ;

GENERIC: image. ( object -- )

M: string image. ( image -- ) load-image image. ;

M: pathname image. ( image -- ) load-image image. ;

M: image image. ( image -- ) <image-gadget> gadget. ;
