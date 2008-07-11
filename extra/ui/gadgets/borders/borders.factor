! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets kernel math
namespaces vectors sequences math.vectors ;
IN: ui.gadgets.borders

TUPLE: border < gadget size fill ;

: new-border ( child class -- border )
    new-gadget
        { 0 0 } >>size
        { 0 0 } >>fill
        [ add-gadget ] keep ; inline

: <border> ( child gap -- border )
    swap border new-border
        swap dup 2array >>size ;

M: border pref-dim*
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

: border-major-rect ( border -- rect )
    dup border-size swap rect-dim over 2 v*n v- <rect> ;

: border-minor-rect ( major border -- rect )
    gadget-child pref-dim
    [ >r rect-bounds r> v- [ 2 / >fixnum ] map v+ ] keep
    <rect> ;

: scale-rect ( rect vec -- loc dim )
    [ v* ] curry >r rect-bounds r> bi@ ;

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
