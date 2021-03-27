! Copyright (C) 2021 Kevin Cope.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes kernel math.rectangles 
models models.arrow namespaces sequences ui ui.gadgets
ui.gadgets.buttons ui.gadgets.glass ui.gadgets.labeled 
ui.gadgets.presentations ui.gadgets.search-tables
ui.gadgets.tables ui.gadgets.wrappers ui.gestures ui.theme 
ui.tools.browser.popups ui.tools.common ;
FROM: ui.gadgets.wrappers => wrapper ;
IN: ui.tools.button-list

TUPLE: button-list-popup < wrapper ;

: <active-buttons-table> ( model -- table )
    [ keys [ ">" swap 2array ] map ] <arrow> trivial-renderer [ second ] <search-table> 
    dup table>>
        [ second active-buttons get at invoke-primary ] >>action
        [ hide-glass ] >>hook
        t >>selection-required?
        10 >>min-rows
        10 >>max-rows
        30 >>min-cols
        30 >>max-cols
    drop
    ;

: <active-buttons-popup> ( model title -- gadget )
    [ <active-buttons-table> white-interior ] dip
    popup-color <framed-labeled-gadget> button-list-popup new-wrapper ;

button-list-popup H{
    { T{ key-down f f "ESC" } [ hide-glass ] }
} set-gestures

: show-active-buttons-popup ( tool -- )
    active-buttons get <model> "Active Buttons" <active-buttons-popup>
    [ hand-loc get-global point>rect show-glass ] [ request-focus ] bi ; inline

