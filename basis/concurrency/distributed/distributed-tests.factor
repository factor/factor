USING: accessors arrays calendar concurrency.distributed
concurrency.messaging io.sockets kernel math namespaces
sequences threads tools.test ;
FROM: concurrency.messaging => receive send ;
IN: concurrency.distributed.tests

CONSTANT: test-ip "127.0.0.1"
CONSTANT: test-port 57234
CONSTANT: test-port2 57235

[ 8 ] [
    local-node get
    test-ip test-port <inet4> start-node
    local-node get swap local-node set-global
    local-node [
        [
            receive first2 [ 3 + ] dip send
            "thread-a" unregister-remote-thread
        ] "Thread A" spawn
        "thread-a" register-remote-thread
        5 self 2array
        test-ip test-port <inet4> "thread-a" <remote-thread> send
        100 seconds receive-timeout
        stop-node
    ] with-variable
] unit-test

[ 15 ] [
    local-node get
    test-ip test-port2 <inet4> start-node
    local-node get swap local-node set-global
    local-node [
        [
            receive dup data>> 3 * swap reply-synchronous
            "thread-s" unregister-remote-thread
        ] "Thread S" spawn "thread-s" register-remote-thread
        5 test-ip test-port2 <inet4> "thread-s" <remote-thread> send-synchronous
        stop-node
    ] with-variable
] unit-test
