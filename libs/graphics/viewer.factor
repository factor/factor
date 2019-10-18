! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: arrays gadgets kernel math namespaces opengl ;
IN: graphics-gadget

TUPLE: graphics-gadget image ;

GENERIC: draw-image ( image -- )
GENERIC: width ( image -- w )
GENERIC: height ( image -- h )

M: graphics-gadget pref-dim*
    graphics-gadget-image
    [ width ] keep height abs 2array ;

M: graphics-gadget graft* ( gadget -- ) drop ;

M: graphics-gadget ungraft* ( gadget -- ) drop ;

M: graphics-gadget draw-gadget* ( gadget -- )
    origin get [
        graphics-gadget-image draw-image
    ] with-translation ;

C: graphics-gadget ( bitmap -- gadget )
  dup delegate>gadget
  [ set-graphics-gadget-image ] keep ;

