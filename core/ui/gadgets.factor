! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays generic hashtables kernel models math
namespaces sequences styles timers ;

SYMBOL: origin

{ 0 0 } origin set-global

TUPLE: rect loc dim ;

M: array rect-loc ;

M: array rect-dim drop { 0 0 } ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc ext ) rect-bounds over v+ ;

: 2rect-extent ( rect rect -- loc1 loc2 ext1 ext2 )
    [ rect-extent ] 2apply swapd ;

: <extent-rect> ( loc ext -- rect ) dupd swap [v-] <rect> ;

: offset-rect ( rect loc -- newrect )
    over rect-loc v+ swap rect-dim <rect> ;

: >absolute ( rect -- rect )
    origin get offset-rect ;

: (rect-intersect) ( rect rect -- array array )
    2rect-extent vmin >r vmax r> ;

: rect-intersect ( rect1 rect2 -- newrect )
    (rect-intersect) <extent-rect> ;

: intersects? ( rect/point rect -- ? )
    (rect-intersect) [v-] { 0 0 } = ;

TUPLE: gadget
pref-dim parent children orientation state
visible? root? clipped? grafted?
interior boundary ;

M: gadget equal? eq? ;

: gadget-child ( gadget -- child ) gadget-children first ;

: nth-gadget ( n gadget -- ) gadget-children nth ;

: <zero-rect> ( -- rect ) { 0 0 } dup <rect> ;

C: gadget ( -- gadget )
    <zero-rect> over set-delegate
    { 0 1 } over set-gadget-orientation
    t over set-gadget-visible? ;

: delegate>gadget ( tuple -- ) <gadget> swap set-delegate ;

: relative-loc ( fromgadget togadget -- loc )
    2dup eq? [
        2drop { 0 0 }
    ] [
        over rect-loc >r
        >r gadget-parent r> relative-loc
        r> v+
    ] if ;

GENERIC: user-input* ( str gadget -- ? )

M: gadget user-input* 2drop t ;

GENERIC: children-on ( rect/point gadget -- list )

M: gadget children-on nip gadget-children ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible?
    [ >absolute intersects? ] [ 2drop f ] if ;

: (pick-up) ( point gadget -- gadget/f )
    dupd children-on <reversed> [ inside? ] find-with nip ;

: translate ( rect/point -- ) rect-loc origin [ v+ ] change ;

: pick-up ( point gadget -- child/f )
    [
        2dup inside? [
            dup translate 2dup (pick-up) dup
            [ nip pick-up ] [ rot 2drop ] if
        ] [ 2drop f ] if
    ] with-scope ;

: max-dim ( dims -- dim ) { 0 0 } [ vmax ] reduce ;

: each-child ( gadget quot -- )
    >r gadget-children r> each ; inline

: each-child-with ( obj gadget quot -- )
    >r gadget-children r> each-with ; inline

: set-gadget-delegate ( gadget tuple -- )
    over [ dup pick [ set-gadget-parent ] each-child-with ] when
    set-delegate ;

: with-gadget ( gadget quot -- )
    [ swap gadget set call ] with-scope ; inline

! Title bar protocol
GENERIC: gadget-title ( gadget -- string )

M: gadget gadget-title drop "Factor" <model> ;

! Selection protocol
GENERIC: gadget-selection? ( gadget -- ? )

M: gadget gadget-selection? drop f ;

GENERIC: gadget-selection ( gadget -- string/f )

M: gadget gadget-selection drop f ;

! Re-firing gestures while mouse held down, etc. Used by
! slider gadgets
TUPLE: timer-gadget quot ;

C: timer-gadget ( gadget -- newgadget )
    [ set-gadget-delegate ] keep ;

M: timer-gadget tick timer-gadget-quot call ;

: start-timer-gadget ( gadget quot -- )
    2dup call
    over >r curry r>
    [ set-timer-gadget-quot ] keep
    100 200 add-timer ; inline

: stop-timer-gadget ( gadget -- )
    dup remove-timer f swap set-timer-gadget-quot ;
