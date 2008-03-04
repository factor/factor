USING: io.sockets io kernel math threads io.encodings.ascii
debugger tools.time prettyprint concurrency.count-downs
namespaces arrays continuations ;
IN: benchmark.sockets

SYMBOL: counter

: number-of-requests 1 ;

: server-addr "127.0.0.1" 7777 <inet4> ;

: server-loop ( server -- )
    dup accept [
        [
            read1 CHAR: x = [
                "server" get dispose
            ] [
                number-of-requests
                [ read1 write1 flush ] times
                counter get count-down
            ] if
        ] with-stream
    ] curry "Client handler" spawn drop server-loop ;

: simple-server ( -- )
<<<<<<< HEAD:extra/benchmark/sockets/sockets.factor
    7777 local-server "benchmark.sockets" ascii [
        read1 CHAR: x = [
            stop-server
        ] [
            20 [ read1 write1 flush ] times
        ] if
    ] with-server ;
=======
    [
        server-addr <server> dup "server" set [
            server-loop
        ] with-disposal
    ] ignore-errors ;
>>>>>>> b80434b2e394480fa317348955b1f7b89e284bde:extra/benchmark/sockets/sockets.factor

: simple-client ( -- )
    server-addr <client> [
        CHAR: b write1 flush
        number-of-requests
        [ CHAR: a dup write1 flush read1 assert= ] times
        counter get count-down
    ] with-stream ;

: stop-server ( -- )
    server-addr <client> [
        CHAR: x write1
    ] with-stream ;

: clients ( n -- )
    dup pprint " clients: " write [
        dup 2 * <count-down> counter set
        [ simple-server ] "Simple server" spawn drop
        yield yield
        [ [ simple-client ] "Simple client" spawn drop ] times
        counter get await
        stop-server
        yield yield
    ] time ;

: socket-benchmarks
    10 clients
    20 clients
    40 clients ;
    ! 80 clients
    ! 160 clients
    ! 320 clients
    ! 640 clients ;

MAIN: socket-benchmarks
