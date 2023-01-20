! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors arrays kernel sequences math byte-arrays
namespaces grouping fry cap images.bitmap ui.gadgets ui.gadgets.packs
ui.gadgets.borders ui.gadgets.grids ui.gadgets.grid-lines
ui.gadgets.labels ui.gadgets.buttons ui.pens ui.pens.solid ui.render
ui opengl opengl.gl images images.loader ;
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
    ! On Windows, white is { 253 253 253 } ?
    [ 10 /i ] map ;

: bitmap= ( bitmap1 bitmap2 -- ? )
    [ bitmap>> twiddle ] same? ;

: check-rendering ( gadget -- )
    screenshot
    [ render-output set-global ]
    [
        "vocab:ui/render/test/reference.bmp" load-image
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
        add-gadget ;

: ui-render-test ( -- )
    <ui-render-test> "Test" open-window ;

MAIN: ui-render-test
