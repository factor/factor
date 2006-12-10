! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays definitions gadgets gadgets-panes
generic hashtables help io kernel namespaces prettyprint styles
threads sequences vectors definitions parser words strings
math listener models errors ;

TUPLE: interactor
history output
continuation quot busy?
use in error-hook ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    <editor> over set-gadget-delegate
    V{ } clone over set-interactor-history
    dup dup set-control-self ;

M: interactor graft*
    f over set-interactor-busy? delegate graft* ;

: write-input ( string input -- )
    <input> presented associate
    [ H{ { font-style bold } } format ] with-nesting ;

: interactor-input. ( string interactor -- )
    interactor-output [
        dup string? [ dup write-input terpri ] [ short. ] if
    ] with-stream* ;

: add-interactor-history ( str interactor -- )
    over empty? [ 2drop ] [ interactor-history push-new ] if ;

: interactor-finish ( obj interactor -- )
    [ editor-text ] keep
    [ interactor-input. ] 2keep
    [ add-interactor-history ] keep
    dup control-model clear-doc
    interactor-continuation continue-with ;

: interactor-eval ( interactor -- )
    [
        [ editor-text ] keep dup interactor-quot call
    ] in-thread drop ;

: interactor-eof ( interactor -- )
    f swap interactor-continuation schedule-thread-with ;

: interactor-commit ( interactor -- )
    dup interactor-busy? [ drop ] [ interactor-eval ] if ;

: interactor-yield ( interactor quot -- )
    over set-interactor-quot
    f over set-interactor-busy?
    [ swap set-interactor-continuation stop ] callcc1 nip ;

M: interactor stream-readln
    [
        interactor-finish
    ] interactor-yield ;

: interactor-call ( quot interactor -- )
    2dup interactor-input.
    interactor-continuation schedule-thread-with ;

M: interactor stream-read
    swap dup zero?
    [ 2drop "" ] [ >r stream-readln r> head ] if ;

: save-in/use ( interactor -- )
    use get over set-interactor-use
    in get over set-interactor-in
    error-hook get swap set-interactor-error-hook ;

: restore-in/use ( interactor -- )
    dup interactor-use use set
    dup interactor-in in set
    interactor-error-hook error-hook set ;

: go-to-error ( interactor error -- )
    dup parse-error-line 1- swap parse-error-col 2array
    over editor-caret set-model mark>caret ;

: handle-parse-error ( interactor error -- )
    dup parse-error? [ 2dup go-to-error delegate ] when
    swap interactor-error-hook call ;

: try-parse ( str interactor -- quot/error/f )
    [
        [
            [
                restore-in/use
                1array \ parse with-datastack dup length 1 =
                [ first ] [ drop f ] if
            ] keep save-in/use
        ] [
            2nip
        ] recover
    ] with-scope ;

: handle-interactive ( str/f interactor -- )
    tuck try-parse {
        { [ dup quotation? ] [ swap interactor-finish ] }
        { [ dup not ] [ drop "\n" swap user-input ] }
        { [ t ] [ handle-parse-error ] }
    } cond ;

M: interactor parse-interactive
    [ save-in/use ] keep
    [ [ handle-interactive ] interactor-yield ] keep
    restore-in/use ;

interactor "interactor" {
    { "Evaluate" T{ key-down f f "RETURN" } [ interactor-commit ] }
    { "Clear input" T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
} define-commands
