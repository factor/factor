! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets generic hashtables kernel math
namespaces vectors sequences math.vectors ;
IN: ui.gadgets.borders

TUPLE: border size fill ;

: <border> ( child gap -- border )
    dup 2array { 0 0 } border construct-boa
    <gadget> over set-delegate
    tuck add-gadget ;

M: border pref-dim*
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

: border-major-rect ( border -- rect )
    dup border-size swap rect-dim over 2 v*n v- <rect> ;

: border-minor-rect ( major border -- rect )
    gadget-child pref-dim
    [ >r rect-bounds r> v- 2 v/n v+ ] keep <rect> ;

: scale-rect ( rect vec -- loc dim )
    [ v* ] curry >r rect-bounds r> 2apply ;

: average-rects ( rect1 rect2 weight -- rect )
    tuck >r >r scale-rect r> r> { 1 1 } swap v- scale-rect
    swapd v+ >r v+ r> <rect> ;

: border-child-rect ( border -- rect )
    dup border-major-rect
    dup pick border-minor-rect
    rot border-fill
    average-rects ;

M: border layout*
    dup border-child-rect swap gadget-child
    over rect-loc over set-rect-loc
    swap rect-dim swap set-layout-dim ;

M: border focusable-child*
    gadget-child ;
