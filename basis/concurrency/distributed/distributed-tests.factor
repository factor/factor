USING: tools.test concurrency.distributed kernel io.files
io.files.temp io.directories arrays io.sockets system
combinators threads math sequences concurrency.messaging
continuations accessors prettyprint ;
FROM: concurrency.messaging => receive send ;
IN: concurrency.distributed.tests

: test-node ( -- addrspec )
    {
        { [ os unix? ] [ "distributed-concurrency-test" temp-file <local> ] }
        { [ os windows? ] [ "127.0.0.1" 1238 <inet4> ] }
    } cond ;

[ ] [ [ "distributed-concurrency-test" temp-file delete-file ] ignore-errors ] unit-test

[ ] [ test-node dup (start-node) ] unit-test

[ ] [
    [
        receive first2 [ 3 + ] dip send
        "thread-a" unregister-remote-thread
    ] "Thread A" spawn
    "thread-a" register-remote-thread
] unit-test

[ 8 ] [
    5 self 2array
    test-node "thread-a" <remote-thread> send

    receive
] unit-test

[ ] [ test-node stop-node ] unit-test
