! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler kernel gadgets-tracks gadgets-scrolling
gadgets-workspace gadgets-panes gadgets-presentations
gadgets-buttons inference errors io math gadgets namespaces ;
IN: gadgets-messages

TUPLE: messages counter errors errors# warnings warnings# ;

M: messages batch-begins
    0 over set-messages-errors#
    0 over set-messages-warnings#
    dup messages-errors pane-clear
    messages-warnings pane-clear ;

M: messages compile-begins
    2drop ;

: messages-errors+
    dup messages-errors# 1+ swap set-messages-errors# ;

: messages-warnings+
    dup messages-warnings# 1+ swap set-messages-warnings# ;

M: messages compile-error
    over inference-error?
    [ over inference-error-major? ]
    [ t ] if
    [ dup messages-errors+ messages-errors ]
    [ dup messages-warnings+ messages-warnings ] if
    [ error. ] with-stream ;

: <messages-button> ( -- gadget )
    "Compiler messages"
    [ drop find-workspace messages select-tool ]
    <bevel-button> ;

M: messages batch-ends
    [
        dup messages-errors# # " compiler error(s), " %
        messages-warnings# # " compiler warning(s)" %
    ] "" make print
    <messages-button> gadget. ;

: <errors> ( gadget -- newgadget )
    <scroller> "Compiler errors" <labelled-gadget> ;

: <warnings> ( gadget -- newgadget )
    <scroller> "Compiler warnings" <labelled-gadget> ;

C: messages ( -- gadget )
    {
        { [ <pane> ] set-messages-errors [ <errors> ] 1/2 }
        { [ <pane> ] set-messages-warnings [ <warnings> ] 1/2 }
    } { 0 1 } make-track* dup batch-begins ;
