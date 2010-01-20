! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency.messaging threads io
io.servers.connection io.encodings.binary assocs init
arrays namespaces kernel accessors ;
FROM: io.sockets => host-name <inet> with-client ;
IN: concurrency.distributed

<PRIVATE

: registered-remote-threads ( -- hash )
   \ registered-remote-threads get-global ;

PRIVATE>

: register-remote-thread ( thread name -- )
    registered-remote-threads set-at ;

: unregister-remote-thread ( name -- )
    registered-remote-threads delete-at ;

: get-remote-thread ( name -- thread )
    dup registered-remote-threads at [ ] [ thread ] ?if ;

SYMBOL: local-node

: handle-node-client ( -- )
    deserialize
    [ first2 get-remote-thread send ] [ stop-this-server ] if* ;

: <node-server> ( addrspec -- threaded-server )
    binary <threaded-server>
        swap >>insecure
        "concurrency.distributed" >>name
        [ handle-node-client ] >>handler ;

: (start-node) ( addrspec addrspec -- )
    local-node set-global <node-server> start-server* ;

: start-node ( port -- )
    host-name over <inet> (start-node) ;

TUPLE: remote-thread node id ;

C: <remote-thread> remote-thread

: send-remote-message ( message node -- )
    binary [ serialize ] with-client ;

M: remote-thread send ( message thread -- )
    [ id>> 2array ] [ node>> ] bi
    send-remote-message ;

M: thread (serialize) ( obj -- )
    id>> [ local-node get-global ] dip <remote-thread>
    (serialize) ;

: stop-node ( node -- )
    f swap send-remote-message ;

[
    H{ } clone \ registered-remote-threads set-global
] "remote-thread-registry" add-startup-hook
