! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons gadgets-frames
gadgets-panes gadgets-search gadgets-scrolling help kernel
models namespaces sequences gadgets-tracks gadgets-workspace ;

TUPLE: help-gadget pane history search ;

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
        {
            [ <help-pane> ]
            set-help-gadget-pane
            [ <scroller> ]
            4/5
        }
        {
            [ "" [ help-gadget call-tool ] <help-search> ]
            set-help-gadget-search
            [ "Help search" <labelled-gadget> ]
            1/5
        }
    } { 0 1 } make-track* ;

M: help-gadget focusable-child* help-gadget-search ;

M: help-gadget call-tool* show-help ;

M: help-gadget tool-scroller help-gadget-pane find-scroller ;

M: help-gadget tool-help drop "ui-help" ;

: help-action ( help-gadget -- link )
    help-gadget-history model-value >link ;

help-gadget "Toolbar" {
    { "Back" T{ key-down f { C+ } "b" } [ help-gadget-history go-back ] }
    { "Forward" T{ key-down f { C+ } "f" } [ help-gadget-history go-forward ] }
    { "Home" T{ key-down f { C+ } "h" } [ go-home ] }
}
link class-operations [ help-action ] modify-operations
[ command-name "Follow" = not ] subset
append
define-commands
