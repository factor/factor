! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math matrices namespaces
sequences styles vectors ;

SYMBOL: origin

@{ 0 0 0 }@ origin global set-hash

TUPLE: rect loc dim ;

M: vector rect-loc ;

M: vector rect-dim drop @{ 0 0 0 }@ ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc dim ) rect-bounds over v+ ;

: >absolute ( rect -- rect )
    rect-bounds >r origin get v+ r> <rect> ;

: intersect ( rect rect -- rect )
    >r rect-extent r> rect-extent swapd vmin >r vmax dup r>
    swap v- @{ 0 0 0 }@ vmax <rect> ;

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
    @{ 0 0 0 }@ dup <rect> over set-delegate
    t over set-gadget-visible? ;

GENERIC: user-input* ( ch gadget -- ? )

M: gadget user-input* 2drop t ;

: invalidate ( gadget -- )
    t swap set-gadget-relayout? ;

DEFER: add-invalid

GENERIC: children-on ( rect/point gadget -- list )

M: gadget children-on ( rect/point gadget -- list )
    nip gadget-children ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible?
    [ >absolute intersects? ] [ 2drop f ] ifte ;

: pick-up-list ( rect/point gadget -- gadget/f )
    dupd children-on reverse-slice [ inside? ] find-with nip ;

: translate ( rect/point -- )
    rect-loc origin [ v+ ] change ;

: pick-up ( rect/point gadget -- gadget )
    2dup inside? [
        [
            dup translate 2dup pick-up-list dup
            [ nip pick-up ] [ rot 2drop ] ifte
        ] with-scope
    ] [ 2drop f ] ifte ;
