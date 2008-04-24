IN: concurrency.distributed.tests
USING: tools.test concurrency.distributed kernel io.files
arrays io.sockets system combinators threads math sequences
concurrency.messaging continuations ;

: test-node
    {
        { [ os unix? ] [ "distributed-concurrency-test" temp-file <local> ] }
        { [ os windows? ] [ "127.0.0.1" 1238 <inet4> ] }
    } cond ;

[ ] [ [ "distributed-concurrency-test" temp-file delete-file ] ignore-errors ] unit-test

[ ] [ test-node dup 1array swap (start-node) ] unit-test

[ ] [ yield ] unit-test

[ ] [
    [
        receive first2 >r 3 + r> send
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
