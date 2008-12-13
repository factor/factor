! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.backend kernel namespaces sequences deques calendar
threads ;
IN: ui.event-loop

: event-loop? ( -- ? )
    {
        { [ stop-after-last-window? get not ] [ t ] }
        { [ graft-queue deque-empty? not ] [ t ] }
        { [ windows get-global empty? not ] [ t ] }
        [ f ]
    } cond ;

HOOK: do-events ui-backend ( -- )

: event-loop ( quot -- ) [ event-loop? ] [ do-events ] [ ] while ;

: ui-wait ( -- ) 10 milliseconds sleep ;
