IN: io.sockets.tests
USING: io.sockets io.sockets.private sequences math tools.test
namespaces accessors kernel destructors calendar io.timeouts
io.encodings.utf8 io concurrency.promises threads
io.streams.string ;

[ B{ 1 2 3 4 } ]
[ "1.2.3.4" T{ inet4 } inet-pton ] unit-test

[ "1.2.3.4" ]
[ B{ 1 2 3 4 } T{ inet4 } inet-ntop ] unit-test

[ "255.255.255.255" ]
[ B{ 255 255 255 255 } T{ inet4 } inet-ntop ] unit-test

[ B{ 255 255 255 255 } ]
[ "255.255.255.255" T{ inet4 } inet-pton ] unit-test

[ B{ 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 } ]
[ "1:2:3:4:5:6:7:8" T{ inet6 } inet-pton ] unit-test

[ "1:2:3:4:5:6:7:8" ]
[ B{ 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 } T{ inet6 } inet-ntop ] unit-test

[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } ]
[ "::" T{ inet6 } inet-pton ] unit-test

[ "0:0:0:0:0:0:0:0" ]
[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } T{ inet6 } inet-ntop ] unit-test

[ B{ 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } ]
[ "1::" T{ inet6 } inet-pton ] unit-test

[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 } ]
[ "::1" T{ inet6 } inet-pton ] unit-test

[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 } ]
[ "::100" T{ inet6 } inet-pton ] unit-test

[ B{ 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 2 } ]
[ "1::2" T{ inet6 } inet-pton ] unit-test

[ B{ 0 1 0 0 0 0 0 0 0 0 0 0 0 2 0 3 } ]
[ "1::2:3" T{ inet6 } inet-pton ] unit-test

[ B{ 0 1 0 2 0 0 0 0 0 0 0 0 0 3 0 4 } ]
[ "1:2::3:4" T{ inet6 } inet-pton ] unit-test

[ "1:2:0:0:0:0:3:4" ]
[ B{ 0 1 0 2 0 0 0 0 0 0 0 0 0 3 0 4 } T{ inet6 } inet-ntop ] unit-test

[ "2001:6f8:37a:5:0:0:0:1" ]
[ "2001:6f8:37a:5::1" T{ inet6 } [ inet-pton ] [ inet-ntop ] bi ] unit-test

[ t ] [ "localhost" 80 <inet> resolve-host length 1 >= ] unit-test

! Smoke-test UDP
[ ] [ "127.0.0.1" 0 <inet4> <datagram> "datagram1" set ] unit-test
[ ] [ "datagram1" get addr>> "addr1" set ] unit-test
[ f ] [ "addr1" get port>> 0 = ] unit-test

[ ] [ "127.0.0.1" 0 <inet4> <datagram> "datagram2" set ] unit-test
[ ] [ "datagram2" get addr>> "addr2" set ] unit-test
[ f ] [ "addr2" get port>> 0 = ] unit-test

[ ] [ B{ 1 2 3 4 } "addr2" get "datagram1" get send ] unit-test
[ B{ 1 2 3 4 } ] [ "datagram2" get receive "from" set ] unit-test
[ ] [ B{ 4 3 2 1 } "from" get "datagram2" get send ] unit-test
[ B{ 4 3 2 1 } t ] [ "datagram1" get receive "addr2" get = ] unit-test

[ ] [ "datagram1" get dispose ] unit-test
[ ] [ "datagram2" get dispose ] unit-test

! Test timeouts
[ ] [ "127.0.0.1" 0 <inet4> <datagram> "datagram3" set ] unit-test

[ ] [ 1 seconds "datagram3" get set-timeout ] unit-test
[ "datagram3" get receive ] must-fail

! See what happens if other end is closed
[ ] [ <promise> "port" set ] unit-test

[ ] [ "datagram3" get dispose ] unit-test

[ ] [
    [
        "127.0.0.1" 0 <inet4> utf8 <server>
        dup addr>> "port" get fulfill
        [
            accept drop
            dup stream-readln drop
            "hello" <string-reader> swap stream-copy
        ] with-disposal
    ] "Socket close test" spawn drop
] unit-test

[ "hello" f ] [
    "port" get ?promise utf8 [
        1 seconds input-stream get set-timeout
        1 seconds output-stream get set-timeout
        "hi\n" write flush readln readln
    ] with-client
] unit-test
