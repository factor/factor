! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar combinators deques kernel namespaces sequences
threads ui ui.private ui.backend ui.gadgets ui.gadgets.private ;
IN: ui.event-loop

: event-loop? ( -- ? )
    {
        { [ graft-queue deque-empty? not ] [ t ] }
        { [ windows get-global empty? not ] [ t ] }
        [ f ]
    } cond ;

HOOK: do-events ui-backend ( -- )

: event-loop ( -- ) [ event-loop? ] [ do-events ] while ;

: ui-wait ( -- ) 10 milliseconds sleep ;
