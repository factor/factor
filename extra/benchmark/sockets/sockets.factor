USING: io.sockets io.server io kernel math threads debugger
concurrency tools.time prettyprint ;
IN: benchmark.sockets

: simple-server ( -- )
    7777 local-server "benchmark.sockets" [
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

: socket-benchmark ( n -- )
    dup pprint " clients: " write
        [
        [ simple-server ] in-thread
        100 sleep
        [ drop simple-client ] parallel-each
        stop-server
        yield yield
    ] time ;

: socket-benchmarks
    10 socket-benchmark
    20 socket-benchmark
    40 socket-benchmark
    80 socket-benchmark
    160 socket-benchmark
    320 socket-benchmark ;

MAIN: socket-benchmarks
