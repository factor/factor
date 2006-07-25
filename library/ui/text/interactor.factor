! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls gadgets-panes hashtables help io
kernel namespaces prettyprint styles threads ;

TUPLE: interactor output continuation ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    f f <field> over set-gadget-delegate
    dup dup set-control-self ;

: interactor-eval ( string gadget -- )
    interactor-continuation dup
    [ [ continue-with ] in-thread ] when 2drop ;

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

: interactor-commit ( gadget -- )
    dup field-commit
    over control-model clear-doc
    swap 2dup print-input interactor-eval ;

interactor H{
    { T{ key-down f f "RETURN" } [ interactor-commit ] }
    { T{ key-down f { C+ } "b" } [ interactor-output pane-clear ] }
    { T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
} set-gestures

M: interactor stream-readln ( pane -- line )
    [ over set-interactor-continuation stop ] callcc1 nip ;
