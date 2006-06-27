! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-search gadgets-tiles
gadgets-tracks help io kernel sequences words ;

TUPLE: history pane seq ;

C: history ( -- gadget )
    V{ } clone over set-history-seq
    <pane> dup pick set-history-pane
    <scroller> "History" f <tile> over set-gadget-delegate ;

: update-history ( history -- )
    dup history-seq swap history-pane [
        <reversed> [
            [ article-title ] keep write-object terpri
        ] each
    ] with-pane ;

TUPLE: help-gadget showing history scroller ;

: help-gadget-pane help-gadget-scroller scroller-gadget ;

C: help-gadget ( -- gadget )
    {
        { [ <history> ] set-help-gadget-history 1/4 }
        { [ <pane> <scroller> ] set-help-gadget-scroller 3/4 }
    } { 1 0 } make-track* ;

M: help-gadget gadget-title
    "Help - " swap help-gadget-showing article-title append ;

: add-history ( help -- )
    dup help-gadget-history
    swap help-gadget-showing dup
    [ over history-seq push-new update-history ] [ 2drop ] if ;

: show-help ( link help -- )
    dup add-history
    [ set-help-gadget-showing ] 2keep
    dup update-title
    help-gadget-pane [ help ] with-pane ;

: help-tool
    [ help-gadget? ]
    [ <help-gadget> ]
    [ show-help ] ;

M: link show ( link -- ) help-tool call-tool ;
