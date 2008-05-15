! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.unix.bsd io.backend io.monitors core-foundation.fsevents
continuations kernel sequences namespaces arrays system locals
accessors destructors ;
IN: io.unix.macosx

TUPLE: macosx-monitor < monitor handle ;

: enqueue-notifications ( triples monitor -- )
    [
        >r first { +modify-file+ } r> queue-change
    ] curry each ;

M:: macosx (monitor) ( path recursive? mailbox -- monitor )
    [let | path [ path normalize-path ] |
        path mailbox macosx-monitor new-monitor
        dup [ enqueue-notifications ] curry
        path 1array 0 0 <event-stream> >>handle
    ] ;

M: macosx-monitor dispose
    handle>> dispose ;

macosx set-io-backend
