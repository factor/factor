IN: concurrency.distributed.tests
USING: tools.test concurrency.distributed kernel io.files
io.files.temp io.directories arrays io.sockets system
combinators threads math sequences concurrency.messaging
continuations accessors prettyprint ;
FROM: concurrency.messaging => receive send ;

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
        "thread-a" unregister-process
    ] "Thread A" spawn
    "thread-a" swap register-process
] unit-test

[ 8 ] [
    5 self 2array
    "thread-a" test-node <remote-process> send

    receive
] unit-test

[ ] [ test-node stop-node ] unit-test
