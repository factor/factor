! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: kernel sequences namespaces assocs graphs math math.order ;

ERROR: no-compilation-unit definition ;

SINGLETON: inlined-dependency
SINGLETON: flushed-dependency
SINGLETON: called-dependency

TUPLE: method-dependency class ;
C: <method-dependency> method-dependency

UNION: dependency
inlined-dependency
flushed-dependency
called-dependency
method-dependency ;

M: dependency <=>
    [
        dup method-dependency? [ drop method-dependency ] when
        {
            called-dependency
            method-dependency
            flushed-dependency
            inlined-dependency
        } index
    ] bi@ <=> ;

SYMBOL: changed-definitions

: changed-definition ( defspec how -- )
    swap changed-definitions get
    [ set-at ] [ no-compilation-unit ] if* ;

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
