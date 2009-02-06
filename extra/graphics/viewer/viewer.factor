! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators graphics.bitmap kernel math
math.functions namespaces opengl opengl.gl ui ui.gadgets
ui.gadgets.panes ui.render ;
IN: graphics.viewer

TUPLE: graphics-gadget < gadget image ;

GENERIC: draw-image ( image -- )
GENERIC: width ( image -- w )
GENERIC: height ( image -- h )

M: graphics-gadget pref-dim*
    image>> [ width ] keep height abs 2array ;

M: graphics-gadget draw-gadget* ( gadget -- )
    origin get [ image>> draw-image ] with-translation ;

: <graphics-gadget> ( bitmap -- gadget )
    \ graphics-gadget new-gadget
        swap >>image ;

M: bitmap draw-image ( bitmap -- )
    dup height>> 0 < [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
    ] [
        0 over height>> abs glRasterPos2i
        1.0 1.0 glPixelZoom
    ] if
    [ width>> ] keep
    [
        [ height>> abs ] keep
        bit-count>> {
            { 32 [ GL_BGRA GL_UNSIGNED_BYTE ] }
            { 24 [ GL_BGR GL_UNSIGNED_BYTE ] }
            { 8 [ GL_BGR GL_UNSIGNED_BYTE ] }
            { 4 [ GL_BGR GL_UNSIGNED_BYTE ] }
        } case
    ] keep array>> glDrawPixels ;

M: bitmap width ( bitmap -- ) width>> ;
M: bitmap height ( bitmap -- ) height>> ;

: bitmap. ( path -- )
    load-bitmap <graphics-gadget> gadget. ;

: bitmap-window ( path -- gadget )
    load-bitmap <graphics-gadget> [ "bitmap" open-window ] keep ;
