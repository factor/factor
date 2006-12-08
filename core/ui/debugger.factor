! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-viewports gadgets-lists
generic hashtables io kernel math models namespaces prettyprint
queues sequences test threads help sequences words timers ;

: <restart-list> ( restarts restart-hook -- gadget )
    [ restart-name ] rot <model> <list> ;

TUPLE: debugger restarts ;

: <debugger-display> ( error restart-list -- gadget )
    >r [ print-error ] make-pane r> 2array make-filled-pile ;

C: debugger ( error restarts restart-hook -- gadget )
    {
        {
            [ gadget get { debugger } <toolbar> ]
            f f @top
        }
        {
            [ <restart-list> ]
            set-debugger-restarts
            [ <debugger-display> <scroller> ]
            @center
        }
    } make-frame* dup popup-theme ;

M: debugger focusable-child*
    debugger-restarts ;

: debugger-window ( error -- )
    #! No restarts for the debugger window
    f [ drop ] <debugger>
    "Error" open-titled-window ;

: ui-try ( quot -- )
    [ debugger-window ] recover ;
