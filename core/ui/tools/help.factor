! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-help
USING: gadgets gadgets-borders gadgets-buttons
gadgets-panes gadgets-scrolling help kernel
models namespaces sequences gadgets-tracks gadgets-workspace
errors operations ;

TUPLE: help-gadget pane history ;

: show-help ( link help -- )
    dup help-gadget-history add-history
    >r >link r> help-gadget-history set-model ;

: <help-pane> ( help-gadget -- gadget )
    help-gadget-history
    [ [ dup help ] try drop ] <pane-control> ;

: init-history ( help-gadget -- )
    "handbook" <history>
    swap set-help-gadget-history ;

C: help-gadget ( -- gadget )
    dup init-history [
        toolbar,
        g <help-pane> g-> set-help-gadget-pane
        <scroller> 1 track,
    ] { 0 1 } build-track ;

M: help-gadget call-tool* show-help ;

M: help-gadget tool-scroller help-gadget-pane find-scroller ;

: help-action ( help-gadget -- link )
    help-gadget-history model-value >link ;

: com-follow help-gadget call-tool ;

: com-back help-gadget-history go-back ;

: com-forward help-gadget-history go-forward ;

: com-home "handbook" swap show-help ;

: help-viewer-help "ui-help" help-window ;

\ help-viewer-help H{ { +nullary+ t } } define-command

help-gadget "toolbar" f {
    { T{ key-down f { A+ } "b" } com-back }
    { T{ key-down f { A+ } "f" } com-forward }
    { T{ key-down f { A+ } "h" } com-home }
    { T{ key-down f f "F1" } help-viewer-help }
} define-command-map
