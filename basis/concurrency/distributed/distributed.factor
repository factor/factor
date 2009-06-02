! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency.messaging threads io
io.servers.connection io.encodings.binary
arrays namespaces kernel accessors ;
FROM: io.sockets => host-name <inet> with-client ;
IN: concurrency.distributed

SYMBOL: local-node

: handle-node-client ( -- )
    deserialize
    [ first2 get-process send ] [ stop-this-server ] if* ;

: <node-server> ( addrspec -- threaded-server )
    binary <threaded-server>
        swap >>insecure
        "concurrency.distributed" >>name
        [ handle-node-client ] >>handler ;

: (start-node) ( addrspec addrspec -- )
    local-node set-global <node-server> start-server* ;

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
    id>> local-node get-global <remote-process>
    (serialize) ;

: stop-node ( node -- )
    f swap send-remote-message ;
