! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.unix.bsd io.backend io.monitors core-foundation.fsevents
continuations kernel sequences namespaces arrays system locals ;
IN: io.unix.macosx

macosx set-io-backend

TUPLE: macosx-monitor < monitor handle ;

: enqueue-notifications ( triples monitor -- )
    tuck monitor-queue
    [ [ first { +modify-file+ } swap changed-file ] each ] bind
    notify-callback ;

M:: macosx (monitor) ( path recursive? mailbox -- monitor )
    path mailbox macosx-monitor construct-monitor
    dup [ enqueue-notifications ] curry
    path 1array 0 0 <event-stream> >>handle ;

M: macosx-monitor dispose
    handle>> dispose ;
