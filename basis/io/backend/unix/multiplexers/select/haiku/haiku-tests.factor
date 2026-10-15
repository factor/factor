USING: accessors alien.c-types alien.data byte-arrays calendar destructors io.backend.unix
io.backend.unix.multiplexers.select.haiku io.sockets io.sockets.private
io.timeouts kernel libc locals math sequences threads tools.test unix.ffi ;
IN: io.backend.unix.multiplexers.select.haiku.tests

{ t } [ <haiku-select-mx> [ dispose ] keep disposed>> ] unit-test
{ f } [ 2147483647 haiku-udp-family ] unit-test

:: idle-datagram ( address -- ready? )
    [ address <datagram> |dispose handle>> handle-fd haiku-udp-ready? ]
    with-destructors ;
{ f } [ "127.0.0.1" 0 <inet4> idle-datagram ] unit-test
{ f } [ "::1" 0 <inet6> idle-datagram ] unit-test

:: peek-real-zero ( address -- received correct-sender? )
    [
        address <datagram> |dispose :> receiver
        address <datagram> |dispose :> sender
        2 seconds receiver set-timeout
        sender handle>> handle-fd B{ 0 } 0 0
        receiver addr>> make-sockaddr/size-outgoing sendto 0 assert=
        50 milliseconds sleep
        receiver handle>> handle-fd haiku-udp-ready? t assert=
        receiver handle>> handle-fd haiku-udp-ready? t assert=
        receiver receive sender addr>> =
    ] with-destructors ;
20 [
    { B{ } t } [ "127.0.0.1" 0 <inet4> peek-real-zero ] unit-test
    { B{ } t } [ "::1" 0 <inet6> peek-real-zero ] unit-test
] times

! Non-socket and stream descriptors remain on the ordinary select path.
{ f f } [
    [
        2 int <c-array> dup pipe io-error
        dup first <fd> &dispose handle-fd haiku-udp-family
        swap second <fd> &dispose handle-fd haiku-udp-family
    ] with-destructors
] unit-test
{ f } [
    [ AF_INET SOCK_STREAM 0 socket dup io-error <fd> &dispose
      handle-fd haiku-udp-family ] with-destructors
] unit-test

:: peek-real-payload ( address -- received correct-sender? )
    [
        address <datagram> |dispose :> receiver
        address <datagram> |dispose :> sender
        2 seconds receiver set-timeout
        "hello world" >byte-array receiver addr>> sender send
        50 milliseconds sleep
        receiver handle>> handle-fd haiku-udp-ready? t assert=
        receiver handle>> handle-fd haiku-udp-ready? t assert=
        receiver receive sender addr>> =
    ] with-destructors ;
{ B{ 104 101 108 108 111 32 119 111 114 108 100 } t }
[ "127.0.0.1" 0 <inet4> peek-real-payload ] unit-test
{ B{ 104 101 108 108 111 32 119 111 114 108 100 } t }
[ "::1" 0 <inet6> peek-real-payload ] unit-test
