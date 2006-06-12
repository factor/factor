! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-tabs gadgets-tiles gadgets-tracks help
io kernel sequences words ;

TUPLE: help-gadget showing history tabs ;

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

: add-history ( help -- )
    dup help-gadget-history swap help-gadget-showing dup
    [ over history-seq push-new update-history ] [ 2drop ] if ;

C: help-gadget ( -- gadget )
    {
        { [ <history> ] set-help-gadget-history 1/4 }
        { [ <tabs> ] set-help-gadget-tabs 3/4 }
    } { 1 0 0 } make-track* ;

M: help-gadget gadget-title
    "Help - " swap help-gadget-showing article-title append ;

: show-help ( link help -- )
    dup add-history [ set-help-gadget-showing ] 2keep
    dup update-title {
        { "Article" [ help ] }
        { "Links in" [ links-in. ] }
    } swap help-gadget-tabs set-pages ;

: help-tool
    [ help-gadget? ]
    [ <help-gadget> ]
    [ show-help ] ;

M: link show-object ( link button -- ) help-tool call-tool ;
