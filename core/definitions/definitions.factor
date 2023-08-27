! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences sets ;
IN: definitions

MIXIN: definition-mixin

ERROR: no-compilation-unit definition ;

: add-to-unit ( key set -- )
    [ adjoin ] [ no-compilation-unit ] if* ;

SYMBOL: changed-definitions

: changed-definition ( defspec -- )
    changed-definitions get add-to-unit ;

SYMBOL: maybe-changed

: changed-conditionally ( class -- )
    maybe-changed get add-to-unit ;

SYMBOL: changed-effects

SYMBOL: outdated-generics

SYMBOL: new-words

: new-word ( word -- )
    new-words get add-to-unit ;

GENERIC: where ( defspec -- loc )

M: object where drop f ;

GENERIC: set-where ( loc defspec -- )

GENERIC: forget* ( defspec -- )

SYMBOL: forgotten-definitions

: forgotten-definition ( defspec -- )
    forgotten-definitions get add-to-unit ;

: forget ( defspec -- )
    [ forgotten-definition ] [ forget* ] bi ;

M: f forget* drop ;

M: wrapper forget* wrapped>> forget ;

: forget-all ( definitions -- ) [ forget ] each ;

GENERIC: definer ( defspec -- start end )

GENERIC: definition ( defspec -- seq )
