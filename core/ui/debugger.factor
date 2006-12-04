! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
DEFER: call-listener

IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-viewports gadgets-lists
generic hashtables io kernel math models namespaces prettyprint
queues sequences test threads help sequences words timers ;

: <debugger-button>
    [ call-listener drop ] curry <bevel-button> ;

: <restart-list> ( error restart-hook -- gadget )
    [ restart-name ] rot compute-restarts <model> <list> ;

TUPLE: debugger restarts ;

: <debugger-display> ( error restart-list -- gadget )
    >r [ print-error ] make-pane r> 2array make-pile
    1 over set-pack-fill ;

C: debugger ( error restart-hook -- gadget )
    {
        {
            [ gadget get { debugger } <toolbar> ]
            f f @top
        }
        {
            [ dupd <restart-list> ]
            set-debugger-restarts
            [ <debugger-display> <scroller> ]
            @center
        }
    } make-frame* dup popup-theme ;

M: debugger focusable-child*
    debugger-restarts ;

debugger "toolbar" {
    { "Data stack" T{ key-down f f "s" } [ :s ] }
    { "Retain stack" T{ key-down f f "r" } [ :r ] }
    { "Call stack" T{ key-down f f "c" } [ :c ] }
    { "Help" T{ key-down f f "h" } [ :help ] }
    { "Edit" T{ key-down f f "e" } [ :edit ] }
} [
    first3 [ call-listener drop ] curry 3array
] map define-commands

: debugger-window ( error -- )
    [ drop ] <debugger>
    "Error" open-titled-window ;

: ui-try ( quot -- )
    [ debugger-window ] recover ;
