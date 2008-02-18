! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: serialize sequences concurrency.messaging
threads io io.server qualified arrays
namespaces kernel ;
QUALIFIED: io.sockets
IN: concurrency.distributed

: handle-node-client ( -- )
    deserialize first2 thread send ;

: (start-node) ( addrspecs addrspec -- )
    [
        local-node set-global
        "concurrency.distributed"
        [ handle-node-client ] with-server
    ] 2curry f spawn drop ;

SYMBOL: local-node ( -- addrspec )

: start-node ( port -- )
    dup internet-server host-name rot <inet> (start-node) ;

TUPLE: remote-thread pid node ;

M: remote-thread send ( message thread -- )
    { remote-thread-pid remote-thread-node } get-slots
    io.sockets:<client> [ 2array serialize ] with-stream ;

M: thread (serialize) ( obj -- )
    thread-id local-node get-global
    remote-thread construct-boa
    (serialize) ;
