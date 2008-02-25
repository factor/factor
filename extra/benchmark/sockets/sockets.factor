USING: io.sockets io.server io kernel math threads io.encodings.ascii
debugger tools.time prettyprint concurrency.combinators ;
IN: benchmark.sockets

: simple-server ( -- )
    7777 local-server "benchmark.sockets" ascii [
        read1 CHAR: x = [
            stop-server
        ] [
            20 [ read1 write1 flush ] times
        ] if
    ] with-server ;

: simple-client ( -- )
    "localhost" 7777 <inet> <client> [
        CHAR: b write1 flush
        20 [ CHAR: a dup write1 flush read1 assert= ] times
    ] with-stream ;

: stop-server ( -- )
    "localhost" 7777 <inet> <client> [
        CHAR: x write1
    ] with-stream ;

: clients ( n -- )
    dup pprint " clients: " write [
        [ simple-server ] in-thread
        yield yield
        [ drop simple-client ] parallel-each
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
