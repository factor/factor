! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces assocs math ;
IN: definitions

MIXIN: definition

ERROR: no-compilation-unit definition ;

SYMBOLS: inlined-dependency flushed-dependency called-dependency ;

: set-in-unit ( value key assoc -- )
    [ set-at ] [ no-compilation-unit ] if* ;

SYMBOL: changed-definitions

: changed-definition ( defspec -- )
    inlined-dependency swap changed-definitions get set-in-unit ;

SYMBOL: changed-effects

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

M: f forget* drop ;

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    dup forgotten-definitions get set-in-unit ;

: forget ( defspec -- ) [ forgotten-definition ] [ forget* ] bi ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )
