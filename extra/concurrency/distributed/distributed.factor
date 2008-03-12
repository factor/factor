! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency.messaging
threads io io.server qualified arrays
namespaces kernel io.encodings.binary ;
QUALIFIED: io.sockets
IN: concurrency.distributed

SYMBOL: local-node

: handle-node-client ( -- )
    deserialize first2 get-process send ;

: (start-node) ( addrspecs addrspec -- )
    [
        local-node set-global
        "concurrency.distributed"
        binary [ handle-node-client ] with-server
    ] 2curry f spawn drop ;

: start-node ( port -- )
    dup internet-server io.sockets:host-name
    rot io.sockets:<inet> (start-node) ;

TUPLE: remote-process id node ;

C: <remote-process> remote-process

M: remote-process send ( message thread -- )
    { remote-process-id remote-process-node } get-slots
    binary io.sockets:<client> [ 2array serialize ] with-stream ;

M: thread (serialize) ( obj -- )
    thread-id local-node get-global
    <remote-process>
    (serialize) ;
