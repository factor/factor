! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors arrays kernel sequences math byte-arrays
namespaces cap graphics.bitmap
ui.gadgets ui.gadgets.packs ui.gadgets.borders ui.gadgets.grids
ui.gadgets.grid-lines ui.gadgets.labels ui.gadgets.buttons
ui.render ui opengl opengl.gl ;
IN: ui.render.test

SINGLETON: line-test

M: line-test draw-interior
    2drop { 0 0 } { 0 10 } gl-line ;

: <line-gadget> ( -- gadget )
    <gadget>
        line-test >>interior
        { 1 10 } >>dim ;

TUPLE: ui-render-test < pack { first-time? initial: t } ;

: message-window ( text -- )
    <label> "Message" open-window ;

: check-rendering ( gadget -- )
    gl-screenshot
    "resource:extra/ui/render/test/reference.bmp" load-bitmap array>>
    = "perfect" "needs work" ? "Your UI rendering is " prepend
    message-window ;

M: ui-render-test draw-gadget*
    [ call-next-method ] [
        dup first-time?>> [
            dup check-rendering
            f >>first-time?
        ] when
        drop
    ] bi ;

: <ui-render-test> ( -- gadget )
    \ ui-render-test new-gadget
        { 1 0 } >>orientation
        <gadget>
            black <solid> >>interior
            { 98 98 } >>dim
        1 <border> add-gadget
        <gadget>
            gray <solid> >>boundary
            { 94 94 } >>dim
        3 <border>
            red <solid> >>boundary
        add-gadget
            <line-gadget> <line-gadget> <line-gadget> 3array
            <line-gadget> <line-gadget> <line-gadget> 3array
            <line-gadget> <line-gadget> <line-gadget> 3array
        3array <grid>
            { 5 5 } >>gap
            blue <grid-lines> >>boundary
        add-gadget
        <gadget>
            { 14 14 } >>dim
            black <checkmark-paint> >>interior
            black <solid> >>boundary
        4 <border>
        add-gadget ;
    
: ui-render-test ( -- )
    <ui-render-test> "Test" open-window ;

MAIN: ui-render-test
