! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons gadgets-labels
gadgets-panes gadgets-presentations gadgets-theme
gadgets-viewports gadgets-lists gadgets-tracks gadgets-scrolling
generic hashtables io kernel math models namespaces prettyprint
queues sequences test threads help sequences words timers ;

: <restart-list> ( restarts restart-hook -- gadget )
    [ restart-name ] rot <model> <list> ;

TUPLE: debugger restarts ;

: <debugger-display> ( restart-list error -- gadget )
    [
        [ print-error ] H{ } make-pane gadget, gadget,
    ] make-filled-pile ;

C: debugger ( error restarts restart-hook -- gadget )
    [
        toolbar,
        <restart-list> g-> set-debugger-restarts
        swap <debugger-display> <scroller> 1 track,
    ] { 0 1 } build-track ;

M: debugger focusable-child* debugger-restarts ;

: debugger-window ( error -- )
    #! No restarts for the debugger window
    f [ drop ] <debugger> "Error" open-window ;

: ui-try ( quot -- )
    [ debugger-window ] recover ;

debugger "gestures" f {
    { T{ button-down } request-focus }
} define-command-map
