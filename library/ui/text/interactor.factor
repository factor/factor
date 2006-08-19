! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls gadgets-panes generic hashtables
help io kernel namespaces prettyprint styles threads sequences
vectors ;

TUPLE: interactor output continuation queue busy? ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    f <field> over set-gadget-delegate
    dup dup set-control-self ;

M: interactor graft*
    f over set-interactor-busy? delegate graft* ;

: interactor-eval ( string interactor -- )
    dup interactor-busy? [
        2drop
    ] [
        t over set-interactor-busy?
        swap "\n" split <reversed> >vector
        over set-interactor-queue
        interactor-continuation schedule-thread
    ] if ;

SYMBOL: structured-input

: interactor-call ( quot gadget -- )
    dup interactor-output [
        "Command: " write over short.
    ] with-stream*
    >r structured-input set-global
    "\"structured-input\" \"gadgets-text\" lookup get-global call"
    r> interactor-eval ;

: print-input ( string interactor -- )
    interactor-output [
        H{ { font-style bold } } [
            dup <input> presented associate
            [ write ] with-nesting terpri
        ] with-style
    ] with-stream* ;

: interactor-commit ( interactor -- )
    dup interactor-busy? [
        drop
    ] [
        dup field-commit
        over control-model clear-doc
        swap 2dup print-input interactor-eval
    ] if ;

interactor H{
    { T{ key-down f f "RETURN" } [ interactor-commit ] }
    { T{ key-down f { C+ } "b" } [ interactor-output pane-clear ] }
    { T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
} set-gestures

M: interactor stream-readln
    dup interactor-queue empty? [
        f over set-interactor-busy?
        [ over set-interactor-continuation stop ] callcc0
    ] when interactor-queue pop ;
