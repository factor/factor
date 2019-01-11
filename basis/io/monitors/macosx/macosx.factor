! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays core-foundation.fsevents destructors fry
io.backend io.monitors kernel locals sequences system ;
IN: io.monitors.macosx

TUPLE: macosx-monitor < monitor handle ;

: enqueue-notifications ( triples monitor -- )
    '[ first { +modify-file+ } _ queue-change ] each ;

M:: macosx (monitor) ( path recursive? mailbox -- monitor )
    path normalize-path :> path
    path mailbox macosx-monitor new-monitor
    dup [ enqueue-notifications ] curry
    path 1array 0 0 <event-stream> >>handle ;

M: macosx-monitor dispose*
    [ handle>> dispose ] [ call-next-method ] bi ;

macosx set-io-backend
