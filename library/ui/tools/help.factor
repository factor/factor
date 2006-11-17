! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons
gadgets-panes gadgets-scrolling help kernel
models namespaces sequences gadgets-tracks gadgets-workspace ;

TUPLE: help-gadget pane history ;

: show-help ( link help -- )
    dup help-gadget-history add-history
    >r >link r> help-gadget-history set-model ;

: go-home ( help -- ) "handbook" swap show-help ;

: <help-pane> ( history -- gadget )
    gadget get help-gadget-history [ help ] <pane-control> ;

: init-history ( help-gadget -- )
    "handbook" <history>
    swap set-help-gadget-history ;

C: help-gadget ( -- gadget )
    dup init-history {
        {
            [ <help-pane> ]
            set-help-gadget-pane
            [ <scroller> ]
            @center
        }
    } make-frame* ;

M: help-gadget call-tool* show-help ;

M: help-gadget tool-scroller help-gadget-pane find-scroller ;

M: help-gadget tool-help drop "ui-help" ;

: help-action ( help-gadget -- link )
    help-gadget-history model-value >link ;
