! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-lists
USING: gadgets kernel sequences models opengl math ;

TUPLE: list index quot color ;

C: list ( model quot -- gadget )
    [ set-list-quot ] keep
    0 over set-list-index
    { 0.8 0.8 1.0 1.0 } over set-list-color
    dup rot <pile> 1 over set-pack-fill delegate>control ;

M: list model-changed
    dup clear-gadget
    dup control-value over list-quot map
    swap add-gadgets ;

M: list draw-gadget*
    dup list-color gl-color
    dup list-index swap gadget-children 2dup bounds-check? [
        nth rect-bounds swap [ gl-fill-rect ] with-translation
    ] [
        2drop
    ] if ;

M: list focusable-child* drop t ;

: select-index ( n list -- )
    dup control-value empty? [
        2drop
    ] [
        [ control-value length rem ] keep
        [ set-list-index ] keep
        relayout-1
    ] if ;

: select-prev ( list -- )
    dup list-index 1- swap select-index ;

: select-next ( list -- )
    dup list-index 1+ swap select-index ;

\ list H{
    { T{ button-down } [ request-focus ] }
    { T{ key-down f f "UP" } [ select-prev ] }
    { T{ key-down f f "DOWN" } [ select-next ] }
} set-gestures
