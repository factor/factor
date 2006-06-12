! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-search gadgets-tabs gadgets-tiles
gadgets-tracks help io kernel sequences words ;

TUPLE: history pane seq ;

C: history ( -- gadget )
    V{ } clone over set-history-seq
    <pane> dup pick set-history-pane
    <scroller> "History" f <tile> over set-gadget-delegate ;

: update-history ( history -- )
    dup history-seq swap history-pane [
        <reversed> [
            [ article-title ] keep simple-object terpri
        ] each
    ] with-pane ;

TUPLE: help-sidebar history search ;

: <help-search> ( -- gadget )
    [ search-help. ] <search-gadget> "Search" f <tile> ;

C: help-sidebar ( -- gadget )
    {
        { [ <history> ] set-help-sidebar-history 1/2 }
        { [ <help-search> ] set-help-sidebar-search 1/2 }
    } { 0 1 0 } make-track* ;

TUPLE: help-gadget showing sidebar tabs ;

C: help-gadget ( -- gadget )
    {
        { [ <help-sidebar> ] set-help-gadget-sidebar 1/4 }
        { [ <tabs> ] set-help-gadget-tabs 3/4 }
    } { 1 0 0 } make-track* ;

M: help-gadget gadget-title
    "Help - " swap help-gadget-showing article-title append ;

M: help-gadget focusable-child*
    help-gadget-sidebar help-sidebar-search ;

: add-history ( help -- )
    dup help-gadget-sidebar help-sidebar-history
    swap help-gadget-showing dup
    [ over history-seq push-new update-history ] [ 2drop ] if ;

: fancy-help ( obj -- )
    link-name dup article-content swap dup word? [
        { $definition } swap add add
    ] [
        drop
    ] if (help) ;

: show-help ( link help -- )
    dup add-history [ set-help-gadget-showing ] 2keep
    dup update-title {
        { "Article" [ fancy-help ] }
        { "Links in" [ links-in. ] }
    } swap help-gadget-tabs set-pages ;

: help-tool
    [ help-gadget? ]
    [ <help-gadget> ]
    [ show-help ] ;

M: link show ( link -- ) help-tool call-tool ;
