! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs definitions.icons help
help.topics kernel math.rectangles models.arrow namespaces
sequences tools.crossref ui.gadgets ui.gadgets.glass
ui.gadgets.labeled ui.gadgets.search-tables ui.gadgets.tables
ui.gadgets.wrappers ui.gestures ui.images ui.operations ui.theme
ui.tools.common ;
FROM: ui.gadgets.wrappers => wrapper ;
IN: ui.tools.browser.popups

SINGLETON: link-renderer

M: link-renderer row-columns
    drop first2 [ definition-icon <image-name> ] dip 2array ;

M: link-renderer row-value drop first ;

TUPLE: links-popup < wrapper ;

: <links-table> ( model quot -- table )
    '[
        @ sort-articles [ article-title ] zip-with
    ] <arrow> link-renderer [ second ] <search-table> dup table>>
        [ invoke-primary-operation ] >>action
        [ hide-glass ] >>hook
        t >>selection-required?
        10 >>min-rows
        10 >>max-rows
        30 >>min-cols
        30 >>max-cols drop ;

: <links-popup> ( model quot title -- gadget )
    [ <links-table> white-interior ] dip
    popup-color <framed-labeled-gadget> links-popup new-wrapper ;

links-popup H{
    { T{ key-down f f "ESC" } [ hide-glass ] }
} set-gestures

SLOT: model

: show-links-popup ( browser-gadget quot title -- )
    [ dup model>> ] 2dip <links-popup>
    [ hand-loc get-global point>rect show-glass ] [ request-focus ] bi ; inline

: com-show-outgoing-links ( browser-gadget -- )
    [ uses ] "Outgoing links" show-links-popup ;

: com-show-incoming-links ( browser-gadget -- )
    [ usage ] "Incoming links" show-links-popup ;
