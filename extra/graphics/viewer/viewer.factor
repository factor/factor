! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.functions namespaces opengl
ui.gadgets ui.render accessors ;
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
