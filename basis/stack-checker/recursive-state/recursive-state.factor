! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences kernel sequences assocs
namespaces stack-checker.recursive-state.tree ;
IN: stack-checker.recursive-state

TUPLE: recursive-state words word quotations inline-words ;

C: <recursive-state> recursive-state

: prepare-recursive-state ( word rstate -- rstate )
    swap >>word
    f >>quotations
    f >>inline-words ; inline

: initial-recursive-state ( word -- state )
    recursive-state new
        f >>words
        prepare-recursive-state ; inline

f initial-recursive-state recursive-state set-global

: add-recursive-state ( word -- rstate )
    recursive-state get clone
        [ word>> dup ] keep [ store ] change-words
        prepare-recursive-state ;

: add-local-quotation ( recursive-state quot -- rstate )
    swap clone [ dupd store ] change-quotations ;

: add-inline-word ( word label -- rstate )
    swap recursive-state get clone
    [ store ] change-inline-words ;

: recursive-word? ( word -- ? )
    recursive-state get 2dup word>> eq?
    [ 2drop t ] [ words>> lookup ] if ;

: inline-recursive-label ( word -- label/f )
    recursive-state get inline-words>> lookup ;

: recursive-quotation? ( quot -- ? )
    recursive-state get quotations>> lookup ;
