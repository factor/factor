! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists namespaces ;

! A gadget is a shape, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent. A gadget
! delegates to its shape.
TUPLE: gadget
    paint gestures
    relayout? redraw?
    parent children delegate ;

C: gadget ( shape -- gadget )
    [ set-gadget-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep
    [ <namespace> swap set-gadget-gestures ] keep
    [ t swap set-gadget-relayout? ] keep
    [ t swap set-gadget-redraw? ] keep ;

: paint-property ( gadget key -- value )
    swap gadget-paint hash ;

: set-paint-property ( gadget value key -- )
    rot gadget-paint set-hash ;

: action ( gadget gesture -- quot )
    swap gadget-gestures hash ;

: set-action ( gadget quot gesture -- )
    rot gadget-gestures set-hash ;

: move-gadget ( x y gadget -- )
    [ move-shape ] keep redraw ;

: resize-gadget ( w h gadget -- )
    [ resize-shape ] keep redraw ;

: box- ( gadget box -- )
    [ 2dup gadget-children remq swap set-gadget-children ] keep
    relayout
    f swap set-gadget-parent ;

: (box+) ( gadget box -- )
    [ gadget-children cons ] keep set-gadget-children ;

: unparent ( gadget -- )
    dup gadget-parent dup [ box- ] [ 2drop ] ifte ;

: box+ ( gadget box -- )
    #! Add a gadget to a box.
    over unparent
    dup pick set-gadget-parent
    tuck (box+)
    relayout ;
