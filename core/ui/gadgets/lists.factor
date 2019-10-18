! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-lists
USING: gadgets gadgets-labels gadgets-scrolling kernel sequences
generic models opengl math namespaces gadgets-theme
gadgets-presentations ;

TUPLE: list index presenter color hook ;

: list-theme ( list -- )
    { 0.8 0.8 1.0 1.0 } swap set-list-color ;

C: list ( hook presenter model -- gadget )
    [ swap <filled-pile> delegate>control ] keep
    [ set-list-presenter ] keep
    [ set-list-hook ] keep
    0 over set-list-index
    dup list-theme ;

: bound-index ( list -- )
    dup list-index over control-value length 1- max 0 min
    swap set-list-index ;

: list-presentation-hook ( list -- quot )
    list-hook [ [ [ list? ] is? ] find-parent ] swap append ;

: <list-presentation> ( hook elt presenter -- gadget )
    keep <presentation>
    [ set-presentation-hook ] keep
    [ text-theme ] keep ;

: <list-items> ( list -- seq )
    dup list-presentation-hook
    over list-presenter
    rot control-value [
        >r 2dup r> swap <list-presentation>
    ] map 2nip ;

M: list model-changed
    dup clear-gadget
    dup <list-items> over add-gadgets
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

: select-previous ( list -- )
    dup list-index 1- swap select-index ;

: select-next ( list -- )
    dup list-index 1+ swap select-index ;

: invoke-value-action ( list -- )
    dup list-empty? [
        dup list-hook call
    ] [
        dup list-index swap nth-gadget invoke-secondary
    ] if ; inline

list "keyboard-navigation" "Lists can be navigated from the keyboard." {
    { T{ button-down } request-focus }
    { T{ key-down f f "UP" } select-previous }
    { T{ key-down f f "DOWN" } select-next }
    { T{ key-down f f "RET" } invoke-value-action }
} define-command-map
