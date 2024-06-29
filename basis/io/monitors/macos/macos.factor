! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators core-foundation.fsevents
destructors io.backend io.monitors kernel math sequences system
;
IN: io.monitors.macos

TUPLE: macos-monitor < monitor handle ;

: enqueue-notifications ( triples monitor -- )
    '[
        first2 V{ } clone swap {
            [ kFSEventStreamEventFlagItemCreated bitand zero? [ +add-file+ suffix! ] unless ]
            [ kFSEventStreamEventFlagItemRemoved bitand zero? [ +remove-file+ suffix! ] unless ]
            [ kFSEventStreamEventFlagItemRenamed bitand zero? [ +rename-file+ suffix! ] unless ]
            [ kFSEventStreamEventFlagItemModified bitand zero? [ +modify-file+ suffix! ] unless ]
        } cleave [ { +modify-file+ } ] [ >array ] if-empty _ queue-change
    ] each ;

M:: macos (monitor) ( path recursive? mailbox -- monitor )
    path normalize-path :> path
    path mailbox macos-monitor new-monitor
    dup [ enqueue-notifications ] curry
    path 1array 0 kFSEventStreamCreateFlagFileEvents <event-stream> >>handle ;

M: macos-monitor dispose*
    [ handle>> dispose ] [ call-next-method ] bi ;

macos set-io-backend
