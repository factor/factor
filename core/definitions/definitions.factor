! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: kernel sequences namespaces assocs graphs ;

ERROR: no-compilation-unit definition ;

SYMBOL: changed-definitions

: changed-definition ( defspec -- )
    dup changed-definitions get
    [ no-compilation-unit ] unless*
    set-at ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget* ( defspec -- )

M: object forget* drop ;

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    dup forgotten-definitions get
    [ no-compilation-unit ] unless*
    set-at ;

: forget ( defspec -- ) dup forgotten-definition forget* ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: synopsis* ( defspec -- )

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )

SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

M: object uses drop f ;

: xref ( defspec -- ) dup uses crossref get add-vertex ;

: usage ( defspec -- seq ) \ f or crossref get at keys ;

: unxref ( defspec -- )
    dup uses crossref get remove-vertex ;

: delete-xref ( defspec -- )
    dup unxref crossref get delete-at ;
