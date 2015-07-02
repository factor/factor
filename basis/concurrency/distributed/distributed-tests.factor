USING: tools.test concurrency.distributed kernel io.files
io.files.temp io.directories arrays io.sockets system calendar
combinators threads math sequences concurrency.messaging
continuations accessors prettyprint io.servers ;
FROM: concurrency.messaging => receive send ;
IN: concurrency.distributed.tests

CONSTANT: test-ip "127.0.0.1"

: test-node-server ( -- threaded-server )
    {
        { [ os unix? ] [ "distributed-concurrency-test" temp-file <local> ] }
        { [ os windows? ] [ test-ip 0 <inet4> ] }
    } cond <node-server> ;

: test-node-client ( -- addrspec )
    {
        { [ os unix? ] [ "distributed-concurrency-test" temp-file <local> ] }
        { [ os windows? ] [ insecure-addr ] }
    } cond ;


{ } [ [ "distributed-concurrency-test" temp-file delete-file ] ignore-errors ] unit-test

test-node-server [
    [ ] [
        [
            receive first2 [ 3 + ] dip send
            "thread-a" unregister-remote-thread
        ] "Thread A" spawn
        "thread-a" register-remote-thread
    ] unit-test

    [ 8 ] [
        5 self 2array
        test-node-client "thread-a" <remote-thread> send
        100 seconds receive-timeout
    ] unit-test
] with-threaded-server
