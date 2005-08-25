! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math matrices namespaces
sequences styles vectors ;

SYMBOL: origin

global [ { 0 0 0 } origin set ] bind

TUPLE: rect loc dim ;

M: vector rect-loc ;

M: vector rect-dim drop { 0 0 0 } ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc dim ) rect-bounds over v+ ;

: >absolute ( rect -- rect )
    rect-bounds >r origin get v+ r> <rect> ;

: intersect ( rect rect -- rect )
    >r rect-extent r> rect-extent swapd vmin >r vmax dup r>
    swap v- { 0 0 0 } vmax <rect> ;

: intersects? ( rect/point rect -- ? )
    >r rect-extent r> rect-extent swapd vmin >r vmax r> v-
    [ 0 <= ] all? ;

! A gadget is a rectangle, a paint, a mapping of gestures to
! actions, and a reference to the gadget's parent.
TUPLE: gadget
    paint gestures visible? relayout? root?
    parent children ;

M: gadget = eq? ;

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
