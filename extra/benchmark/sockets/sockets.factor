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
    [
        server-addr ascii <server> dup "server" set [
            server-loop
        ] with-disposal
    ] ignore-errors ;

: simple-client ( -- )
    server-addr ascii <client> [
        CHAR: b write1 flush
        number-of-requests
        [ CHAR: a dup write1 flush read1 assert= ] times
        counter get count-down
    ] with-stream ;

: stop-server ( -- )
    server-addr ascii <client> [
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

: socket-benchmarks ;

MAIN: socket-benchmarks
