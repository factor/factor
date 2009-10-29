! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency.messaging threads io
io.servers.connection io.encodings.binary assocs init
arrays namespaces kernel accessors ;
FROM: io.sockets => host-name <inet> with-client ;
IN: concurrency.distributed

<PRIVATE

: registered-processes ( -- hash )
   \ registered-processes get-global ;

PRIVATE>

: register-process ( name process -- )
    swap registered-processes set-at ;

: unregister-process ( name -- )
    registered-processes delete-at ;

: get-process ( name -- process )
    dup registered-processes at [ ] [ thread ] ?if ;

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

[
    H{ } clone \ registered-processes set-global
] "remote-thread-registry" add-init-hook


