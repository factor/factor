! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces
stack-checker.recursive-state.tree ;
IN: stack-checker.recursive-state

TUPLE: recursive-state quotations inline-words ;

: <recursive-state> ( -- state ) recursive-state new ; inline

<recursive-state> recursive-state set-global

: add-local-quotation ( rstate quot -- rstate )
    swap clone [ dupd store ] change-quotations ;

: add-inline-word ( word label -- rstate )
    swap recursive-state get clone [ store ] change-inline-words ;

: inline-recursive-label ( word -- label/f )
    recursive-state get inline-words>> lookup ;

: recursive-quotation? ( quot -- ? )
    recursive-state get quotations>> lookup ;
