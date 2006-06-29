! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays generic hashtables kernel math
namespaces sequences styles ;

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

: >absolute ( rect -- rect )
    rect-bounds >r origin get v+ r> <rect> ;

: (rect-intersect) ( rect rect -- array array )
    2rect-extent vmin >r vmax r> ;

: rect-intersect ( rect rect -- rect )
    (rect-intersect) <extent-rect> ;

: intersects? ( rect/point rect -- ? )
    (rect-intersect) [v-] { 0 0 } = ;

TUPLE: gadget
    pref-dim parent children orientation
    visible? relayout? root? clipped? interior boundary ;

M: gadget = eq? ;

: gadget-child gadget-children first ;

C: gadget ( -- gadget )
    { 0 0 } dup <rect> over set-delegate
    { 0 1 } over set-gadget-orientation
    t over set-gadget-visible? ;

: delegate>gadget ( tuple -- ) <gadget> swap set-delegate ;

GENERIC: user-input* ( str gadget -- ? )

M: gadget user-input* 2drop t ;

GENERIC: children-on ( rect/point gadget -- list )

M: gadget children-on ( rect/point gadget -- list )
    nip gadget-children ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible?
    [ >absolute intersects? ] [ 2drop f ] if ;

: pick-up-list ( rect/point gadget -- gadget/f )
    dupd children-on <reversed> [ inside? ] find-with nip ;

: translate ( rect/point -- new-origin )
    rect-loc origin [ v+ ] change ;

: pick-up ( rect/point gadget -- gadget )
    [
        2dup inside? [
            dup translate 2dup pick-up-list dup
            [ nip pick-up ] [ rot 2drop ] if
        ] [ 2drop f ] if
    ] with-scope ;

: max-dim ( dims -- dim ) { 0 0 } [ vmax ] reduce ;

: each-child ( gadget quot -- )
    >r gadget-children r> each ; inline

: each-child-with ( obj gadget quot -- )
    >r gadget-children r> each-with ; inline

: set-gadget-delegate ( delegate gadget -- )
    dup pick [ set-gadget-parent ] each-child-with set-delegate ;

! Pointer help protocol
GENERIC: gadget-help

M: gadget gadget-help drop f ;
