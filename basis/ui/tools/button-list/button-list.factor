! Copyright (C) 2021 Kevin Cope.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes kernel math.rectangles 
models models.arrow namespaces sequences ui ui.gadgets
ui.gadgets.buttons ui.gadgets.glass ui.gadgets.labeled 
ui.gadgets.presentations ui.gadgets.search-tables
ui.gadgets.labels ui.gadgets.tables ui.gadgets.wrappers ui.gestures
ui.theme ui.tools.browser.popups ui.tools.common ;
FROM: ui.gadgets.wrappers => wrapper ;
IN: ui.tools.button-list

TUPLE: button-list-popup < wrapper ;

MIXIN: clickable
INSTANCE: button clickable

SYMBOL: active-buttons
active-buttons [ H{ } ] initialize

: label-from-button ( button -- str/f )
    children>> [ label? ] find swap [ text>> ] [ drop f ] if ;

: store-labelled-button ( button -- str/f )
    dup label-from-button [ [ active-buttons get set-at ] keep ] [ drop f ] if* ;

: remove-labelled-button ( button -- str/f )
    label-from-button [ dup active-buttons get delete-at ] [ f ] if* ;

M: clickable graft* [ store-labelled-button drop ] [ call-next-method ] bi ;
M: button ungraft* [ remove-labelled-button drop ] [ call-next-method ] bi ;

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

