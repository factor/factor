USING: continuations io.sockets io.sockets.private sequences math
tools.test namespaces accessors kernel destructors calendar io.timeouts
io.encodings.utf8 io concurrency.promises threads
io.streams.string present system ;
IN: io.sockets.tests

os unix? [
    [ T{ local f "/tmp/foo" } ] [ "/tmp/foo" <local> ] unit-test
] when

[ T{ inet4 f f 0 } ] [ f 0 <inet4> ] unit-test
[ T{ inet6 f f 0 1 } ] [ f 1 <inet6> ] unit-test

[ T{ inet f "google.com" f } ] [ "google.com" f <inet> ] unit-test

[ T{ inet f "google.com" 0 } ] [ "google.com" 0 <inet> ] unit-test
[ T{ inet f "google.com" 80 } ] [ "google.com" 0 <inet> 80 with-port ] unit-test
[ T{ inet4 f "8.8.8.8" 0 } ] [ "8.8.8.8" 0 <inet4> ] unit-test
[ T{ inet4 f "8.8.8.8" 53 } ] [ "8.8.8.8" 0 <inet4> 53 with-port ] unit-test
[ T{ inet6 f "5:5:5:5:6:6:6:6" 0 12 } ] [ "5:5:5:5:6:6:6:6" 0 <inet6> 12 with-port ] unit-test
[ T{ inet6 f "fe80::1" 1 80 } ] [ T{ ipv6 f "fe80::1" 1 } 80 with-port ] unit-test

: test-sockaddr ( addrspec -- )
    [ dup make-sockaddr ] keep parse-sockaddr assert= ;

[ ] [ T{ inet4 f "8.8.8.8" 53 } test-sockaddr ] unit-test
[ ] [ T{ inet6 f "5:5:5:5:6:6:6:6" 0 12 } test-sockaddr ] unit-test
[ ] [ T{ inet6 f "fe80:0:0:0:0:0:0:1" 1 80 } test-sockaddr ] unit-test

[ T{ inet f "google.com" 80 } ] [ "google.com" 80 with-port ] unit-test

! Test bad hostnames
[ "google.com" f <inet4> ] must-fail
[ "a.b.c.d" f <inet4> ] must-fail
[ "google.com" f <inet6> ] must-fail
[ "a.b.c.d" f <inet6> ] must-fail

! Test present on addrspecs
[ "4.4.4.4:12" ] [ "4.4.4.4" 12 <inet4> present ] unit-test
[ "::1:12" ] [ "::1" 12 <inet6> present ] unit-test
[ "fe80::1%1:12" ] [ "fe80::1" 1 12 inet6 boa present ] unit-test

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

[ B{ 0 0 0 0 0 0 0 0 0 127 0 0 0 0 0 1 } ]
[ "::127.0.0.1" T{ inet6 } inet-pton ] unit-test

[ B{ 0 2 0 0 0 0 0 9 0 127 0 0 0 0 0 1 } ]
[ "2::9:127.0.0.1" T{ inet6 } inet-pton ] unit-test

[ "2001:6f8:37a:5:0:0:0:1" ]
[ "2001:6f8:37a:5::1" T{ inet6 } [ inet-pton ] [ inet-ntop ] bi ] unit-test

[ t t ] [
    "localhost" 80 <inet> resolve-host
    [ length 1 >= ]
    [ [ [ inet4? ] [ inet6? ] bi or ] all? ] bi
] unit-test

[ t t ] [
    "localhost" resolve-host
    [ length 1 >= ]
    [ [ [ ipv4? ] [ ipv6? ] bi or ] all? ] bi
] unit-test

[ t t ] [
    f resolve-host
    [ length 1 >= ]
    [ [ [ ipv4? ] [ ipv6? ] bi or ] all? ] bi
] unit-test

[ t t ] [
    f 0 <inet> resolve-host
    [ length 1 >= ]
    [ [ [ ipv4? ] [ ipv6? ] bi or ] all? ] bi
] unit-test

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

! Binding to all interfaces should work
[ ] [ f 0 <inet4> <datagram> dispose ] unit-test
[ ] [ f 0 <inet6> <datagram> dispose ] unit-test

[ 80 ] [ "http" protocol-port ] unit-test
[ f ] [ f protocol-port ] unit-test

[ t ] [
    [ "you-cant-resolve-me!" resolve-host ] [ addrinfo-error? ] recover
] unit-test
