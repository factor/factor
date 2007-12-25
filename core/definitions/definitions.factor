! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: kernel sequences namespaces assocs graphs continuations ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget ( defspec -- )

M: object forget drop ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: synopsis* ( defspec -- )

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )

SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

M: object uses drop f ;

: xref ( defspec -- ) dup uses crossref get add-vertex ;

: usage ( defspec -- seq ) crossref get at keys ;

GENERIC: redefined* ( defspec -- )

M: object redefined* drop ;

: redefined ( defspec -- )
    [ crossref get at ] closure [ drop redefined* ] assoc-each ;

: unxref ( defspec -- )
    dup uses crossref get remove-vertex ;

: delete-xref ( defspec -- )
    dup unxref crossref get delete-at ;

SYMBOL: changed-words
SYMBOL: changed-generics
SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error construct-boa
    { { "Continue" t } } throw-restarts drop ;

: add-once ( key assoc -- )
    2dup key? [ over redefine-error ] when dupd set-at ;

: (remember-definition) ( definition loc assoc -- )
    >r over set-where r> add-once ;

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: remember-class ( class loc -- )
    over new-definitions get first key? [ dup redefine-error ] when
    new-definitions get second (remember-definition) ;

TUPLE: forward-error word ;

: forward-error ( word -- )
    \ forward-error construct-boa throw ;

: forward-reference? ( word -- ? )
    dup old-definitions get assoc-stack
    [ new-definitions get assoc-stack not ]
    [ drop f ] if ;

SYMBOL: recompile-hook
SYMBOL: make-generic-hook

: <definitions> ( -- pair ) { H{ } H{ } } [ clone ] map ;

: with-compilation-unit ( quot -- new-defs )
    [
        H{ } clone changed-words set
        H{ } clone changed-generics set
        <definitions> new-definitions set
        <definitions> old-definitions set
        [
            changed-generics get keys make-generic-hook get call
            changed-words get keys recompile-hook get call
        ] [ ] cleanup
    ] with-scope ; inline
