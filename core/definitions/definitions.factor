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
SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error construct-boa
    { { "Continue" t } } throw-restarts drop ;

: redefinition? ( definition -- ? )
    new-definitions get key? ;

: (save-location) ( definition loc -- )
    over redefinition? [ over redefine-error ] when
    over set-where
    dup new-definitions get set-at ;

TUPLE: forward-error word ;

: forward-error ( word -- )
    \ forward-error construct-boa throw ;

SYMBOL: recompile-hook

: with-compilation-unit ( quot -- new-defs )
    [
        H{ } clone changed-words set
        H{ } clone new-definitions set
        old-definitions off
        call
        changed-words get keys recompile-hook get call
    ] with-scope ; inline
