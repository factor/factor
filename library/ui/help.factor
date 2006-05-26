! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-tabs gadgets-tiles gadgets-tracks help
io kernel sequences words ;

TUPLE: help-gadget history tabs ;

TUPLE: history pane seq ;

C: history ( -- gadget )
    V{ } clone over set-history-seq
    <pane> dup pick set-history-pane
    <scroller> "History" f <tile> over set-gadget-delegate ;

: update-history ( history -- )
    dup history-seq swap history-pane [
        <reversed> 1 swap tail [
            [ article-title ] keep simple-object terpri
        ] each
    ] with-pane ;

: add-history ( link history -- )
    [ history-seq push-new ] keep update-history ;

C: help-gadget ( -- gadget )
    {
        { [ <history> ] set-help-gadget-history 1/4 }
        { [ <tabs> ] set-help-gadget-tabs 3/4 }
    } { 1 0 0 } make-track* ;

: show-help ( link help -- )
    2dup help-gadget-history add-history {
        { "Article" [ help ] }
        { "Links in" [ links-in. ] }
        { "Links out" [ links-out. ] }
    } swap help-gadget-tabs set-pages ;

: help-tool
    [ help-gadget? ]
    [ <help-gadget> ]
    [ show-help ] ;

M: link show-object ( link button -- ) help-tool call-tool ;
