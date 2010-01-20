! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math threads io io.sockets
io.encodings.ascii io.streams.duplex debugger tools.time
prettyprint concurrency.count-downs concurrency.promises
namespaces arrays continuations destructors ;
IN: benchmark.sockets

SYMBOL: counter
SYMBOL: port-promise
SYMBOL: server

CONSTANT: number-of-requests 1000

: server-addr ( -- addr )
    "127.0.0.1" port-promise get ?promise <inet4> ;

: server-loop ( server -- )
    dup accept drop [
        [
            read1 CHAR: x = [
                server get dispose
            ] [
                number-of-requests
                [ read1 write1 flush ] times
            ] if
        ] with-stream
    ] curry "Client handler" spawn drop server-loop ;

: simple-server ( -- )
    [
        "127.0.0.1" 0 <inet4> ascii <server>
        [ server set ]
        [ addr>> port>> port-promise get fulfill ]
        [ [ server-loop ] with-disposal ]
        tri
    ] ignore-errors ;

: simple-client ( -- )
    [
        server-addr ascii [
            CHAR: b write1 flush
            number-of-requests
            [ CHAR: a dup write1 flush read1 assert= ] times
        ] with-client
    ] try
    counter get count-down ;

: stop-server ( -- )
    server-addr ascii [
        CHAR: x write1
    ] with-client ;

: clients ( n -- )
    dup pprint " clients: " write [
        <promise> port-promise set
        dup <count-down> counter set
        [ simple-server ] "Simple server" spawn drop
        yield yield
        [ [ simple-client ] "Simple client" spawn drop ] times
        counter get await
        stop-server
        yield yield
    ] benchmark . flush ;

: socket-benchmarks ( -- )
    1 clients
    10 clients
    20 clients
    40 clients
    100 clients ;

MAIN: socket-benchmarks
