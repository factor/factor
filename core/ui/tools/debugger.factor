! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-debugger
USING: errors sequences gadgets gadgets-buttons gadgets-listener
gadgets-panes gadgets-lists gadgets-scrolling gadgets-theme
kernel models arrays namespaces ;

: <debugger-button>
    [ call-listener drop ] curry <bevel-button> ;

: <restart-list> ( seq -- gadget )
    [ drop ] [ restart-name ] rot <model> <list> ;

TUPLE: debugger restarts ;

: <debugger-display> ( error restart-list -- gadget )
    >r [ error. ] make-pane r>
    2array make-pile
    1 over set-pack-fill ;

C: debugger ( error restarts -- gadget )
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

debugger "toolbar" {
    { "Data stack" T{ key-down f f "s" } [ :s ] }
    { "Retain stack" T{ key-down f f "r" } [ :r ] }
    { "Call stack" T{ key-down f f "c" } [ :c ] }
    { "Help" T{ key-down f f "h" } [ :help ] }
    { "Edit" T{ key-down f f "e" } [ :edit ] }
} [
    first3 [ call-listener drop ] curry 3array
] map define-commands
