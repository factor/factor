IN: io.unix.macosx
USING: io.unix.bsd io.backend io.monitors io.monitors.private
continuations kernel core-foundation.fsevents sequences
namespaces arrays ;

TUPLE: macosx-io ;

INSTANCE: macosx-io bsd-io

T{ macosx-io } set-io-backend

TUPLE: macosx-monitor ;

: enqueue-notifications ( triples monitor -- )
    monitor-queue [
        [ first { +modify-file+ } swap changed-file ] each
    ] bind ;

M: macosx-io <monitor>
    drop
    f macosx-monitor construct-simple-monitor
    dup [ enqueue-notifications ] curry
    rot 1array 0 0 <event-stream>
    over set-simple-monitor-handle ;

M: macosx-monitor dispose
    dup simple-monitor-handle dispose delegate dispose ;

