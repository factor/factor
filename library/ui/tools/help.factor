! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons gadgets-frames
gadgets-panes gadgets-search
gadgets-scrolling help kernel models namespaces sequences ;

TUPLE: help-gadget history ;

: show-help ( link help -- )
    dup help-gadget-history add-history
    help-gadget-history set-model ;

: go-home ( help -- ) "handbook" swap show-help ;

help-gadget {
    { f "Back" T{ key-down f f "b" } [ help-gadget-history go-back ] }
    { f "Forward" T{ key-down f f "f" } [ help-gadget-history go-forward ] }
    { f "Home" T{ key-down f f "h" } [ go-home ] }
} define-commands

: <help-pane> ( -- gadget )
    gadget get help-gadget-history [ help ] <pane-control> ;

C: help-gadget ( -- gadget )
    f <history> over set-help-gadget-history {
        { [ gadget get <toolbar> ] f f @top }
        { [ <help-pane> <scroller> ] f f @center }
    } make-frame* ;

M: help-gadget gadget-title
    help-gadget-history
    [ "Help - " swap article-title append ] <filter> ;

M: help-gadget pref-dim* drop { 500 600 } ;

: help-tool [ help-gadget? ] [ <help-gadget> ] [ show-help ] ;

: handbook-window ( -- )
    T{ link f "handbook" } help-tool call-tool ;

link 1 "Browse" [ help-tool call-tool ] define-operation
