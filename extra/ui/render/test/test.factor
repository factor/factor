! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors arrays kernel sequences math byte-arrays
namespaces grouping fry cap graphics.bitmap
ui.gadgets ui.gadgets.packs ui.gadgets.borders ui.gadgets.grids
ui.gadgets.grid-lines ui.gadgets.labels ui.gadgets.buttons
ui.render ui opengl opengl.gl colors.constants ;
IN: ui.render.test

SINGLETON: line-test

M: line-test draw-interior
    2drop { 0 0 } { 0 10 } gl-line ;

: <line-gadget> ( -- gadget )
    <gadget>
        line-test >>interior
        { 1 10 } >>dim ;

: message-window ( text -- )
    <label> "Message" open-window ;

SYMBOL: render-output

: twiddle ( bytes -- bytes )
    #! On Windows, white is { 253 253 253 } ?
    [ 10 /i ] map ;

: stride ( bitmap -- n ) width>> 3 * ;

: bitmap= ( bitmap1 bitmap2 -- ? )
    [
        dup [ [ height>> ] [ stride ] bi * ] [ array>> length ] bi = [
            [ [ array>> ] [ stride 4 align ] bi group ] [ stride ] bi
            '[ _ head twiddle ] map
        ] unless
    ] bi@ = ;

: check-rendering ( gadget -- )
    screenshot
    [ render-output set-global ]
    [
        "resource:extra/ui/render/test/reference.bmp" load-bitmap
        bitmap= "is perfect" "needs work" ?
        "Your UI rendering " prepend
        message-window
    ] bi ;

TUPLE: take-screenshot { first-time? initial: t } ;

M: take-screenshot draw-boundary
    dup first-time?>> [
        over check-rendering
        f >>first-time?
    ] when
    2drop ;

: <ui-render-test> ( -- gadget )
    <shelf>
        take-screenshot new >>boundary
        <gadget>
            COLOR: black <solid> >>interior
            { 98 98 } >>dim
        { 1 1 } <border> add-gadget
        <gadget>
            COLOR: gray <solid> >>boundary
            { 94 94 } >>dim
        { 3 3 } <border>
            COLOR: red <solid> >>boundary
        add-gadget
            <line-gadget> <line-gadget> <line-gadget> 3array
            <line-gadget> <line-gadget> <line-gadget> 3array
            <line-gadget> <line-gadget> <line-gadget> 3array
        3array <grid>
            { 5 5 } >>gap
            COLOR: blue <grid-lines> >>boundary
        add-gadget
        <gadget>
            { 14 14 } >>dim
            COLOR: black <checkmark-paint> >>interior
            COLOR: black <solid> >>boundary
        { 4 4 } <border>
        add-gadget ;
    
: ui-render-test ( -- )
    <ui-render-test> "Test" open-window ;

MAIN: ui-render-test
