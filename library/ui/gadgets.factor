! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math matrices namespaces
sequences styles vectors ;

! A gadget is a shape, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent. A gadget
! delegates to its shape.
TUPLE: gadget
    paint gestures visible? relayout? root?
    parent children ;

: gadget-child gadget-children first ;

C: gadget ( -- gadget )
    { 0 0 0 } dup <rectangle> over set-delegate
    t over set-gadget-visible? ;

DEFER: add-invalid

: invalidate ( gadget -- )
    t swap set-gadget-relayout? ;

: relayout ( gadget -- )
    #! Relayout and redraw a gadget and its parent before the
    #! next iteration of the event loop.
    dup gadget-relayout? [
        drop
    ] [
        dup invalidate
        dup gadget-root?
        [ add-invalid ]
        [ gadget-parent [ relayout ] when* ] ifte
    ] ifte ;

: (relayout-down)
    dup invalidate gadget-children [ (relayout-down) ] each ;

: relayout-down ( gadget -- )
    #! Relayout a gadget and its children.
    dup add-invalid (relayout-down) ;

: set-gadget-dim ( dim gadget -- )
    2dup shape-dim =
    [ 2drop ] [ [ set-shape-dim ] keep relayout-down ] ifte ;

GENERIC: pref-dim ( gadget -- dim )

M: gadget pref-dim shape-dim ;

GENERIC: layout* ( gadget -- )

: prefer ( gadget -- ) dup pref-dim swap set-gadget-dim ;

M: gadget layout* drop ;

GENERIC: user-input* ( ch gadget -- ? )

M: gadget user-input* 2drop t ;

GENERIC: focusable-child* ( gadget -- gadget/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- gadget )
    dup focusable-child*
    dup t = [ drop ] [ nip focusable-child ] ifte ;
