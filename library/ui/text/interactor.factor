! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays definitions gadgets gadgets-panes
generic hashtables help io kernel namespaces prettyprint styles
threads sequences vectors definitions parser words strings
math ;

TUPLE: interactor history output continuation queue busy? ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    <editor> over set-gadget-delegate
    V{ } clone over set-interactor-history
    dup dup set-control-self ;

M: interactor graft*
    f over set-interactor-busy? delegate graft* ;

: (interactor-eval) ( string interactor -- )
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
    r> (interactor-eval) ;

: interactor-input. ( string interactor -- )
    interactor-output [ dup print-input ] with-stream* ;

: interactor-eval ( string interactor -- )
    dup control-model clear-doc
    over empty? [ 2dup interactor-history push-new ] unless
    2dup interactor-input.
    (interactor-eval) ;

: interactor-commit ( interactor -- )
    dup interactor-busy? [
        drop
    ] [
        [ editor-text ] keep interactor-eval
    ] if ;

M: interactor stream-readln
    dup interactor-queue empty? [
        f over set-interactor-busy?
        [ over set-interactor-continuation stop ] callcc0
    ] when interactor-queue pop ;

M: interactor stream-read
    swap dup zero?
    [ 2drop "" ] [ >r stream-readln r> head ] if ;

interactor "interactor" {
    { "Evaluate" T{ key-down f f "RETURN" } [ interactor-commit ] }
    { "Clear input" T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
} define-commands
