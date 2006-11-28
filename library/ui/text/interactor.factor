! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays definitions gadgets gadgets-panes
generic hashtables help io kernel namespaces prettyprint styles
threads sequences vectors definitions parser words strings
math listener ;

TUPLE: interactor
history output
continuation quot busy?
use in ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    <editor> over set-gadget-delegate
    V{ } clone over set-interactor-history
    dup dup set-control-self ;

M: interactor graft*
    f over set-interactor-busy? delegate graft* ;

: interactor-input. ( string interactor -- )
    interactor-output [
        dup string? [
            dup print-input
        ] [
            5 line-limit set .
        ] if
    ] with-stream* ;

: interactor-finish ( obj interactor -- )
    2dup interactor-input.
    dup control-model clear-doc
    interactor-continuation schedule-thread-with ;

: interactor-eval ( interactor -- )
    [ editor-text ] keep dup interactor-quot call ;

: interactor-eof ( interactor -- )
    f swap dup interactor-quot call ;

: interactor-commit ( interactor -- )
    dup interactor-busy? [ drop ] [ interactor-eval ] if ;

: interactor-yield ( interactor quot -- )
    over set-interactor-quot
    f over set-interactor-busy?
    [ swap set-interactor-continuation stop ] callcc1 ;

M: interactor stream-readln
    [
        over empty? [ 2dup interactor-history push-new ] unless
        interactor-finish
    ] interactor-yield nip ;

: interactor-call ( quot interactor -- )
    2dup interactor-input.
    interactor-continuation schedule-thread-with ;

M: interactor stream-read
    swap dup zero?
    [ 2drop "" ] [ >r stream-readln r> head ] if ;

: try-parse ( str -- quot ? )
    [
        1array \ parse with-datastack
        dup length 1 = [ first t ] [ drop f f ] if
    ] with-scope ;

: handle-interactive ( str/f interactor -- )
    over [
        >r try-parse [
            r> interactor-finish
        ] [
            "\n" r> user-input drop
        ] if
    ] [
        interactor-finish
    ] if ;

M: interactor parse-interactive
    [ handle-interactive ] interactor-yield nip ;

interactor "interactor" {
    { "Evaluate" T{ key-down f f "RETURN" } [ interactor-commit ] }
    { "Clear input" T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
} define-commands
