! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-lists
USING: gadgets gadgets-scrolling kernel sequences models opengl
math namespaces ;

TUPLE: list index presenter action color ;

: list-theme ( list -- )
    { 0.8 0.8 1.0 1.0 } swap set-list-color ;

C: list ( model presenter action -- gadget )
    [ set-list-action ] keep
    [ set-list-presenter ] keep
    dup rot <pile> 1 over set-pack-fill delegate>control
    0 over set-list-index
    dup list-theme ;

: bound-index ( list -- )
    dup list-index over control-value length 1- max 0 min
    swap set-list-index ;

M: list model-changed
    dup clear-gadget
    dup control-value over list-presenter map over add-gadgets
    bound-index ;

: selected-rect ( list -- rect )
    dup list-index swap gadget-children 2dup bounds-check?
    [ nth ] [ 2drop f ] if ;

M: list draw-gadget*
    origin get [
        dup list-color gl-color
        selected-rect [ rect-extent gl-fill-rect ] when*
    ] with-translation ;

M: list focusable-child* drop t ;

: list-value ( list -- object )
    dup list-index swap control-value ?nth ;

: scroll>selected ( list -- )
    #! We change the rectangle's width to zero to avoid
    #! scrolling right.
    [ selected-rect rect-bounds { 0 1 } v* <rect> ] keep
    scroll>rect ;

: list-empty? ( list -- ? ) control-value empty? ;

: select-index ( n list -- )
    dup list-empty? [
        2drop
    ] [
        [ control-value length rem ] keep
        [ set-list-index ] keep
        [ relayout-1 ] keep
        scroll>selected
    ] if ;

: select-prev ( list -- )
    dup list-index 1- swap select-index ;

: select-next ( list -- )
    dup list-index 1+ swap select-index ;

: call-action ( list -- )
    dup list-empty? [
        dup list-value over list-action call
    ] unless drop ;

: click-list ( list -- )
    hand-gadget get [ gadget-parent list? ] find-parent
    dup [
        over gadget-children index dup -1 =
        [ 2drop ] [ swap select-index ] if
    ] [
        2drop
    ] if ;

list H{
    { T{ button-down } [ dup request-focus click-list ] }
    { T{ drag } [ click-list ] }
    { T{ key-down f f "UP" } [ select-prev ] }
    { T{ key-down f f "DOWN" } [ select-next ] }
    { T{ key-down f f "RETURN" } [ call-action ] }
} set-gestures
