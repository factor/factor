! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists namespaces ;

! Gadget protocol.
GENERIC: pick-up* ( point gadget -- gadget/t )
GENERIC: handle-gesture* ( gesture gadget -- ? )

: pick-up ( point gadget -- gadget )
    #! pick-up* returns t to mean 'this gadget', avoiding the
    #! exposed facade issue.
    tuck pick-up* dup t = [ drop ] [ nip ] ifte ;

! A gadget is a shape together with paint, and a reference to
! the gadget's parent. A gadget delegates to its shape.
TUPLE: gadget paint parent delegate ;

C: gadget ( shape -- gadget )
    [ set-gadget-delegate ] keep
    [ <namespace> swap set-gadget-paint ] keep ;

: paint-property ( gadget key -- value )
    swap gadget-paint hash ;

: set-paint-property ( gadget value key -- )
    rot gadget-paint set-hash ;

: with-gadget ( gadget quot -- )
    #! All drawing done inside the quotation is done with the
    #! gadget's paint. If the gadget does not have any custom
    #! paint, just call the quotation.
    >r gadget-paint r> bind ;

M: gadget draw ( gadget -- )
    dup [ gadget-delegate draw ] with-gadget ;

M: gadget pick-up* inside? ;

M: gadget handle-gesture* 2drop t ;

GENERIC: redraw ( gadget -- )

: move-gadget ( x y gadget -- )
    [ move-shape ] keep
    [ set-gadget-delegate ] keep
    redraw ;

: resize-gadget ( w h gadget -- )
    [ resize-shape ] keep
    [ set-gadget-delegate ] keep
    redraw ;

! An invisible gadget.
WRAPPER: ghost
M: ghost draw drop ;
M: ghost pick-up* 2drop f ;
