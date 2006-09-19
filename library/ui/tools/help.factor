! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons gadgets-frames
gadgets-panes gadgets-search gadgets-scrolling help kernel
models namespaces sequences gadgets-tracks gadgets-workspace ;

TUPLE: help-gadget history search ;

: show-help ( link help -- )
    dup help-gadget-history add-history
    help-gadget-history set-model ;

: go-home ( help -- ) "handbook" swap show-help ;

: <help-pane> ( history -- gadget )
    gadget get help-gadget-history [ help ] <pane-control> ;

: init-history ( help-gadget -- )
    T{ link f "handbook" } <history>
    swap set-help-gadget-history ;

C: help-gadget ( -- gadget )
    dup init-history {
        { [ <help-pane> ] f [ <scroller> ] 4/5 }
        { [ [ search-help. ] <search-gadget> ] set-help-gadget-search f 1/5 }
    } { 0 1 } make-track* ;

M: help-gadget focusable-child* help-gadget-search ;

M: help-gadget call-tool* show-help ;

: help-action ( help-gadget -- link )
    help-gadget-history model-value <link> ;
