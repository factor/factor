! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays generic hashtables kernel models math
namespaces sequences styles timers quotations ;

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

: (rect-union) ( rect rect -- array array )
    2rect-extent vmax >r vmin r> ;

: rect-union ( rect1 rect2 -- newrect )
    (rect-union) <extent-rect> ;

TUPLE: gadget
pref-dim parent children orientation state focus
visible? root? clipped? grafted?
interior boundary ;

M: gadget equal? 2drop f ;

M: gadget hashcode* drop gadget hashcode* ;

: gadget-child ( gadget -- child ) gadget-children first ;

: nth-gadget ( n gadget -- child ) gadget-children nth ;

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

GENERIC: children-on ( rect/point gadget -- seq )

M: gadget children-on nip gadget-children ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible?
    [ >absolute intersects? ] [ 2drop f ] if ;

: (pick-up) ( point gadget -- gadget/f )
    dupd children-on [ inside? ] find-last-with nip ;

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

! Selection protocol
GENERIC: gadget-selection? ( gadget -- ? )

M: gadget gadget-selection? drop f ;

GENERIC: gadget-selection ( gadget -- string/f )

M: gadget gadget-selection drop f ;

: gadget-copy ( gadget clipboard -- )
    over gadget-selection? [
        >r [ gadget-selection ] keep r> copy-clipboard
    ] [
        2drop
    ] if ;

: com-copy clipboard get gadget-copy ;

: com-copy-selection selection get gadget-copy ;

! Text protocol
GENERIC: gadget-text* ( gadget -- )

GENERIC: gadget-text-separator ( gadget -- str )

M: gadget gadget-text-separator
    gadget-orientation { 0 1 } = "\n" "" ? ;

: gadget-seq-text ( seq gadget -- )
    gadget-text-separator swap
    [ dup % ] [ gadget-text* ] interleave drop ;

M: gadget gadget-text*
    dup gadget-children swap gadget-seq-text ;

M: array gadget-text*
    [ gadget-text* ] each ;

: gadget-text ( gadget -- string ) [ gadget-text* ] "" make ;
