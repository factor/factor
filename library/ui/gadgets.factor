! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math matrices namespaces
sequences styles vectors ;

SYMBOL: origin

global [ { 0 0 0 } origin set ] bind

TUPLE: rect loc dim ;

GENERIC: inside? ( loc rect -- ? )

: rect-bounds ( rect -- loc dim )
    dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc dim )
    dup rect-loc dup rot rect-dim v+ ;

: screen-loc ( rect -- loc )
    rect-loc origin get v+ ;

: screen-bounds ( rect -- rect )
    dup screen-loc swap rect-dim <rect> ;

M: rectangle inside? ( loc rect -- ? )
    screen-bounds rect-bounds { 1 1 1 } v- { 0 0 0 } vmax
    >r v- { 0 0 0 } r> vbetween? conjunction ;

: intersect ( rect rect -- rect )
    >r rect-extent r> rect-extent swapd vmin >r vmax dup r>
    swap v- { 0 0 0 } vmax <rect> ;

: intersects? ( rect rect -- ? )
    >r rect-extent r> rect-extent swapd vmin >r vmax r> v-
    [ 0 < ] contains? ;

! A gadget is a rectangle, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent.
TUPLE: gadget
    paint gestures visible? relayout? root?
    parent children ;

: gadget-child gadget-children first ;

C: gadget ( -- gadget )
    { 0 0 0 } dup <rect> over set-delegate
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
    2dup rect-dim =
    [ 2drop ] [ [ set-rect-dim ] keep relayout-down ] ifte ;

GENERIC: pref-dim ( gadget -- dim )

M: gadget pref-dim rect-dim ;

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

GENERIC: pick-up* ( point gadget -- gadget )

: pick-up-list ( point gadgets -- gadget )
    [
        dup gadget-visible? [ inside? ] [ 2drop f ] ifte
    ] find-with nip ;

M: gadget pick-up* ( point gadget -- gadget )
    gadget-children pick-up-list ;

: pick-up ( point gadget -- gadget )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    dup gadget-visible? >r 2dup inside? r> drop [
        [ rect-loc v- ] keep 2dup
        pick-up* [ pick-up ] [ nip ] ?ifte
    ] [
        2drop f
    ] ifte ;
