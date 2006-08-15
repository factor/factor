! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons gadgets-frames
gadgets-panes gadgets-presentations gadgets-search
gadgets-scrolling help kernel models namespaces sequences ;

TUPLE: help-gadget history ;

: show-help ( link help -- )
    dup help-gadget-history add-history
    help-gadget-history set-model ;

: go-home ( help -- ) "handbook" swap show-help ;

: find-help-gadget [ help-gadget? ] find-parent ;

: history-action find-help-gadget help-gadget-history ;

: <help-toolbar> ( -- gadget )
    [
        "Back" [ history-action go-back ] <bevel-button> ,
        "Forward" [ history-action go-forward ] <bevel-button> ,
        "Home" [ find-help-gadget go-home ] <bevel-button> ,
        <spacing> ,
        "Search" [ drop search-help-window ] <bevel-button> ,
    ] make-toolbar ;

: <help-pane> ( -- gadget )
    gadget get help-gadget-history [ help ] <pane-control> ;

C: help-gadget ( -- gadget )
    f <history> over set-help-gadget-history {
        { [ <help-toolbar> ] f f @top }
        { [ <help-pane> <scroller> ] f f @center }
    } make-frame* ;

M: help-gadget gadget-title
    help-gadget-history
    [ "Help - " swap article-title append ] <filter> ;

M: help-gadget pref-dim*
    drop { 500 600 } ;

: help-tool
    [ help-gadget? ]
    [ <help-gadget> ]
    [ show-help ] ;

M: link show help-tool call-tool ;
