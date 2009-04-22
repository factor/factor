! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences kernel sequences assocs
namespaces stack-checker.recursive-state.tree ;
IN: stack-checker.recursive-state

TUPLE: recursive-state word quotations inline-words ;

: initial-recursive-state ( word -- state )
    recursive-state new
        swap >>word
        f >>quotations
        f >>inline-words ; inline

f initial-recursive-state recursive-state set-global

: add-local-quotation ( rstate quot -- rstate )
    swap clone [ dupd store ] change-quotations ;

: add-inline-word ( word label -- rstate )
    swap recursive-state get clone
    [ store ] change-inline-words ;

: inline-recursive-label ( word -- label/f )
    recursive-state get inline-words>> lookup ;

: recursive-quotation? ( quot -- ? )
    recursive-state get quotations>> lookup ;
