! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-buttons gadgets-frames gadgets-panes
gadgets-presentations gadgets-scrolling gadgets-search
gadgets-tiles gadgets-tracks help io kernel models namespaces
sequences words ;

TUPLE: help-gadget showing history pane ;

: find-help-gadget [ help-gadget? ] find-parent ;

: go-back ( help -- )
    dup help-gadget-history dup empty? [
        2drop
    ] [
        pop swap help-gadget-showing set-model
    ] if ;

: add-history ( help -- )
    dup help-gadget-showing model-value dup [
        swap help-gadget-history push
    ] [
        2drop
    ] if ;

: show-help ( link help -- )
    dup add-history
    [ help-gadget-showing set-model ] keep
    dup update-title ;

: go-home ( help -- ) "handbook" swap show-help ;

: <help-toolbar> ( -- gadget )
    [
        "Back" [ find-help-gadget go-back ] <bevel-button> ,
        "Home" [ find-help-gadget go-home ] <bevel-button> ,
    ] make-toolbar ;

: <help-pane> ( -- gadget )
    gadget get help-gadget-showing [ help ] <pane-control> ;

C: help-gadget ( -- gadget )
    V{ } over set-help-gadget-history
    f <model> over set-help-gadget-showing {
        { [ <help-toolbar> ] f f @top }
        { [ <help-pane> <scroller> ] f f @center }
    } make-frame* ;

M: help-gadget gadget-title
    "Help - " swap help-gadget-showing model-value
    article-title append ;

: help-tool
    [ help-gadget? ]
    [ <help-gadget> ]
    [ show-help ] ;

M: link show ( link -- ) help-tool call-tool ;
