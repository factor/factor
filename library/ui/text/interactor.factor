! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls gadgets-panes generic hashtables
help io kernel namespaces prettyprint styles threads sequences
vectors jedit definitions parser words ;

TUPLE: interactor history output continuation queue busy? ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    f <field> over set-gadget-delegate
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
    2dup interactor-history push-new
    2dup interactor-input.
    (interactor-eval) ;

: interactor-commit ( interactor -- )
    dup interactor-busy? [
        drop
    ] [
        [ field-commit ] keep interactor-eval
    ] if ;

: quot-action ( interactor word -- )
    over interactor-busy? [
        2drop
    ] [
        [ "[ " % over field-commit % " ] " % % ] "" make
        swap interactor-eval
    ] if ;

: interactor-history. ( interactor -- )
    dup interactor-output [
        "History:" print
        interactor-history [ dup print-input ] each
    ] with-stream* ;

: word-action ( interactor word -- )
    over gadget-selection?
    [ over T{ word-elt } editor-select-prev ] unless
    over gadget-selection add* swap interactor-call ;

: usable-words ( -- seq )
    use get [ hash-values natural-sort ] map concat prune ;

: use-word ( str -- )
    words-named [ word-vocabulary dup print use+ ] each ;

interactor H{
    { T{ key-down f f "RETURN" } [ interactor-commit ] }
    { T{ key-down f { C+ } "h" } [ dup [ interactor-history. ] curry swap interactor-call ] }
    { T{ key-down f { C+ } "b" } [ dup [ interactor-output pane-clear ] curry swap interactor-call ] }
    { T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
    { T{ key-down f { C+ } "i" } [ "infer ." quot-action ] }
    { T{ key-down f { C+ } "w" } [ "walk" quot-action ] }
    { T{ key-down f { A+ } "s" } [ [ search see ] word-action ] }
    { T{ key-down f { A+ } "j" } [ [ search jedit ] word-action ] }
    { T{ key-down f { A+ } "r" } [ [ search reload ] word-action ] }
    { T{ key-down f { A+ } "a" } [ [ apropos ] word-action ] }
    { T{ key-down f { A+ } "u" } [ [ use-word ] word-action ] }
    { T{ key-down f f "TAB" } [ [ usable-words (apropos) ] word-action ] }
} set-gestures

M: interactor stream-readln
    dup interactor-queue empty? [
        f over set-interactor-busy?
        [ over set-interactor-continuation stop ] callcc0
    ] when interactor-queue pop ;
