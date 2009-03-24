! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces assocs graphs math math.order ;
IN: definitions

ERROR: no-compilation-unit definition ;

SYMBOLS: inlined-dependency flushed-dependency called-dependency ;

: set-in-unit ( value key assoc -- )
    [ set-at ] [ no-compilation-unit ] if* ;

SYMBOL: changed-definitions

: changed-definition ( defspec -- )
    inlined-dependency swap changed-definitions get set-in-unit ;

SYMBOL: changed-effects

: changed-effect ( word -- )
    dup changed-effects get set-in-unit ;

SYMBOL: changed-generics

SYMBOL: outdated-generics

SYMBOL: new-classes

: new-class ( word -- )
    dup new-classes get set-in-unit ;

: new-class? ( word -- ? )
    new-classes get key? ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget* ( defspec -- )

M: object forget* drop ;

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    dup forgotten-definitions get set-in-unit ;

: forget ( defspec -- ) [ forgotten-definition ] [ forget* ] bi ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: synopsis* ( defspec -- )

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )

SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

M: object uses drop f ;

: xref ( defspec -- ) dup uses crossref get add-vertex ;

: usage ( defspec -- seq ) crossref get at keys ;

GENERIC: irrelevant? ( defspec -- ? )

M: object irrelevant? drop f ;

GENERIC: smart-usage ( defspec -- seq )

M: f smart-usage drop \ f smart-usage ;

M: object smart-usage usage [ irrelevant? not ] filter ;

: unxref ( defspec -- )
    dup uses crossref get remove-vertex ;

: delete-xref ( defspec -- )
    dup unxref crossref get delete-at ;
