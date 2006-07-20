! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-panes io kernel namespaces prettyprint
styles threads ;

TUPLE: interactor output continuation ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    f <field> over set-gadget-delegate ;

: interactor-eval ( string gadget -- )
    interactor-continuation dup
    [ [ continue-with ] in-thread ] [ 2drop ] if ;

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
        dup [
            <input> presented set
            bold font-style set
        ] make-hash format terpri
    ] with-stream* ;

: interactor-commit ( gadget -- )
    dup field-commit
    swap 2dup print-input interactor-eval ;

interactor H{
    { T{ key-down f f "RETURN" } [ interactor-commit ] }
    { T{ key-down f { C+ } "l" } [ interactor-output pane-clear ] }
    { T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
} set-gestures

M: interactor stream-readln ( pane -- line )
    [ over set-interactor-continuation stop ] callcc1 nip ;
