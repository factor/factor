! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: arrays kernel math math.functions namespaces opengl
ui.gadgets ui.render ;
IN: graphics.viewer

TUPLE: graphics-gadget image ;

GENERIC: draw-image ( image -- )
GENERIC: width ( image -- w )
GENERIC: height ( image -- h )

M: graphics-gadget pref-dim*
    graphics-gadget-image
    [ width ] keep height abs 2array ;

M: graphics-gadget draw-gadget* ( gadget -- )
    origin get [
        graphics-gadget-image draw-image
    ] with-translation ;

: <graphics-gadget> ( bitmap -- gadget )
    \ graphics-gadget construct-gadget
    [ set-graphics-gadget-image ] keep ;

