! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency io io.server qualified
threads arrays namespaces kernel ;
QUALIFIED: io.sockets
IN: concurrency.distributed

TUPLE: node hostname port ;

C: <node> node

: handle-node-client ( -- )
    deserialize first2 get-process send ;

: node-server ( port -- )
    internet-server
    "concurrency"
    [ handle-node-client ] with-server ;

: send-to-node ( msg pid  host port -- )
    io.sockets:<inet> io.sockets:<client> [
        2array serialize
    ] with-stream ;

: localnode ( -- node )
    \ localnode get ;

: start-node ( hostname port -- )
    [ node-server ] in-thread
    <node> \ localnode set-global ;

TUPLE: remote-process node pid ;

C: <remote-process> remote-process

M: remote-process send ( message process -- )
    #! Send the message via the inter-node protocol
    { remote-process-pid remote-process-node } get-slots
    { node-hostname node-port } get-slots
    send-to-node ;

M: process (serialize) ( obj -- )
    localnode swap process-pid <remote-process> (serialize) ;
