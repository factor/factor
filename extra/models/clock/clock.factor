! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar fry kernel models namespaces timers ;
IN: models.clock

TUPLE: clock < model timer ;

: <clock> ( -- model )
    now clock new-model ;

M: clock model-activated
    dup '[ now _ set-model ] f 1 seconds <timer>
    [ start-timer ] keep >>timer drop ;

M: clock model-deactivated
    dup timer>> [ stop-timer ] when* f >>timer drop ;

: clock-model ( -- model )
    \ clock-model get-global [
        <clock> dup \ clock-model set-global
    ] unless* ;
