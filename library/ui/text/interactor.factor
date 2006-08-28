! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: arrays definitions gadgets gadgets-controls gadgets-panes
generic hashtables help io kernel namespaces prettyprint styles
threads sequences vectors definitions parser words ;

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

: interactor-history. ( -- )
    stdio get dup duplex-stream-out [
        duplex-stream-in interactor-history
        [ dup print-input ] each
    ] with-stream* ;

: token-action ( interactor quot -- )
    over gadget-selection?
    [ over T{ word-elt } select-elt ] unless
    over gadget-selection add* swap interactor-call ;

: word-action ( interactor quot -- )
    \ search add* token-action ;

: usable-words ( -- seq )
    use get [ hash-values natural-sort ] map concat prune ;

interactor [
    { f "Evaluate" T{ key-down f f "RETURN" } [ interactor-commit ] } ,
    { f "History" T{ key-down f { C+ } "h" } [ [ interactor-history. ] swap interactor-call ] } ,
    { f "Send EOF" T{ key-down f { C+ } "d" } [ f swap interactor-eval ] } ,

    {
        { f "See" T{ key-down f { A+ } "s" } [ see ] }
        { f "Help" T{ key-down f { A+ } "h" } [ help ] }
        { f "Callers" T{ key-down f { A+ } "u" } [ usage. ] }
        { f "Edit" T{ key-down f { A+ } "e" } [ edit ] }
        { f "Reload" T{ key-down f { A+ } "r" } [ reload ] }
        { f "Watch" T{ key-down f { A+ } "w" } [ watch ] }
    } [ first4 [ word-action ] curry 4array ] map %

    {
        { f "Apropos (all)" T{ key-down f { A+ } "a" } [ apropos ] }
        { f "Apropos (used)" T{ key-down f f "TAB" } [ usable-words (apropos) ] }
    } [ first4 [ token-action ] curry 4array ] map %
] { } make define-commands

M: interactor stream-readln
    dup interactor-queue empty? [
        f over set-interactor-busy?
        [ over set-interactor-continuation stop ] callcc0
    ] when interactor-queue pop ;
