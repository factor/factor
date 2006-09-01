! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons gadgets-frames
gadgets-panes gadgets-search gadgets-scrolling help kernel
models namespaces sequences gadgets-tracks ;

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

: <help-pane> ( history -- gadget )
    gadget get help-gadget-history [ help ] <pane-control> ;

: init-history ( help-gadget -- )
    T{ link f "handbook" } <history>
    swap set-help-gadget-history ;

C: help-gadget ( -- gadget )
    dup init-history {
        { [ <help-pane> ] f f 4/5 }
        { [ [ search-help. ] <search-gadget> ] f f 1/5 }
    } { 1 0 } make-track* ;
