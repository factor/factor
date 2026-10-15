USING: accessors byte-arrays calendar destructors io.backend.unix
io.sockets io.sockets.private io.sockets.unix.haiku io.timeouts kernel locals
sequences tools.test unix.ffi ;
IN: io.sockets.unix.haiku.tests

:: udp-packet-at ( bytes addrspec -- received correct-sender? )
    [
        addrspec <datagram> |dispose :> receiver
        addrspec <datagram> |dispose :> sender
        2 seconds receiver set-timeout
        bytes receiver addr>> sender send
        receiver receive sender addr>> =
    ] with-destructors ;

:: udp-packet ( bytes -- received correct-sender? )
    bytes "127.0.0.1" 0 <inet4> udp-packet-at ;

! Inject a genuine native zero packet with a nonempty backing buffer.
! This tests receiving empty packets, independently of public empty-send.
:: udp-zero-packet-at ( addrspec -- received correct-sender? )
    [
        addrspec <datagram> |dispose :> receiver
        addrspec <datagram> |dispose :> sender
        2 seconds receiver set-timeout
        sender handle>> handle-fd B{ 0 } 0 0
        receiver addr>> make-sockaddr/size-outgoing sendto 0 assert=
        receiver receive sender addr>> =
    ] with-destructors ;

:: udp-zero-packet ( -- received correct-sender? )
    "127.0.0.1" 0 <inet4> udp-zero-packet-at ;

{ B{ } t } [ udp-zero-packet ] unit-test
{ B{ } t } [ B{ } udp-packet ] unit-test
{ B{ 104 101 108 108 111 } t } [ "hello" >byte-array udp-packet ] unit-test
{ B{ 104 101 108 108 111 32 119 111 114 108 100 } t }
[ "hello world" >byte-array udp-packet ] unit-test

! An idle local socket must wait and retain ordinary timeouts,
! including the stock AF_UNIX zero result with an untouched sender buffer.
:: missing-reply ( -- )
    [
        "client" <local> <datagram> |dispose :> client
        100 milliseconds client set-timeout
        client receive 2drop
    ] with-destructors ;

[ [ missing-reply ] with-test-directory ] [ io-timeout? ] must-fail-with

! Stock Haiku IPv6 loopback must retain the same empty/nonempty readiness.
{ B{ } t } [ "::1" 0 <inet6> udp-zero-packet-at ] unit-test
{ B{ } t } [ B{ } "::1" 0 <inet6> udp-packet-at ] unit-test
{ B{ 104 101 108 108 111 } t }
[ "hello" >byte-array "::1" 0 <inet6> udp-packet-at ] unit-test
{ B{ 104 101 108 108 111 32 119 111 114 108 100 } t }
[ "hello world" >byte-array "::1" 0 <inet6> udp-packet-at ] unit-test
