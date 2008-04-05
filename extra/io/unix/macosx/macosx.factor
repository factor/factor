USING: io.backend io.monitors io.monitors.private
continuations kernel core-foundation.fsevents sequences
namespaces arrays system ;
IN: io.unix.macosx

macosx set-io-backend

TUPLE: macosx-monitor ;

: enqueue-notifications ( triples monitor -- )
    tuck monitor-queue
    [ [ first { +modify-file+ } swap changed-file ] each ] bind
    notify-callback ;

M: macosx <monitor>
    drop
    f macosx-monitor construct-simple-monitor
    dup [ enqueue-notifications ] curry
    rot 1array 0 0 <event-stream>
    over set-simple-monitor-handle ;

M: macosx-monitor dispose
    dup simple-monitor-handle dispose delegate dispose ;
