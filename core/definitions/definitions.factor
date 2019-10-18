! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces sequences ;
IN: definitions

MIXIN: definition

ERROR: no-compilation-unit definition ;

: set-in-unit ( value key assoc -- )
    [ set-at ] [ no-compilation-unit ] if* ;

SYMBOL: changed-definitions

: changed-definition ( defspec -- )
    dup changed-definitions get set-in-unit ;

SYMBOL: maybe-changed

: changed-conditionally ( class -- )
    dup maybe-changed get set-in-unit ;

SYMBOL: changed-effects

SYMBOL: outdated-generics

SYMBOL: new-words

: new-word ( word -- )
    dup new-words get set-in-unit ;

: new-word? ( word -- ? )
    new-words get key? ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget* ( defspec -- )

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    dup forgotten-definitions get set-in-unit ;

: forget ( defspec -- ) [ forgotten-definition ] [ forget* ] bi ;

M: f forget* drop ;

M: wrapper forget* wrapped>> forget ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )
