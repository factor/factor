USING: io.sockets io.server io kernel math threads debugger
concurrency tools.time prettyprint ;
IN: benchmark.sockets

: simple-server ( -- )
    7777 local-server "simple-server" [
        10 [ read1 write1 flush ] times
    ] with-server ;

: simple-client ( -- )
    "localhost" 7777 <inet> <client> [
        10 [ CHAR: a dup write1 flush read1 assert= ] times
    ] with-stream ;

: socket-benchmark ( n -- )
    dup pprint " clients: " write
    [ simple-server ] in-thread
    yield yield
    [ drop simple-client ] parallel-each ;

: socket-benchmarks
    [ 10 socket-benchmark ] time
    [ 20 socket-benchmark ] time
    [ 40 socket-benchmark ] time
    [ 80 socket-benchmark ] time
    [ 160 socket-benchmark ] time
    [ 320 socket-benchmark ] time ;

MAIN: socket-benchmarks
