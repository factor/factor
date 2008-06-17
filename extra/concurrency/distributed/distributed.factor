! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency.messaging threads io
io.servers.connection io.encodings.binary
qualified arrays namespaces kernel accessors ;
FROM: io.sockets => host-name <inet> with-client ;
IN: concurrency.distributed

SYMBOL: local-node

: handle-node-client ( -- )
    deserialize
    [ first2 get-process send ] [ stop-server ] if* ;

: (start-node) ( addrspec addrspec -- )
    local-node set-global
    [
        <threaded-server>
            swap >>insecure
            binary >>encoding
            "concurrency.distributed" >>name
            [ handle-node-client ] >>handler
    ] curry "Distributed concurrency server" spawn drop ;

: start-node ( port -- )
    host-name over <inet> (start-node) ;

TUPLE: remote-process id node ;

C: <remote-process> remote-process

: send-remote-message ( message node -- )
    binary [ serialize ] with-client ;

M: remote-process send ( message thread -- )
    [ id>> 2array ] [ node>> ] bi
    send-remote-message ;

M: thread (serialize) ( obj -- )
    thread-id local-node get-global <remote-process>
    (serialize) ;

: stop-node ( node -- )
    f swap send-remote-message ;
