
USING: accessors destructors kernel io.sockets io.sockets.icmp
sequences tools.test ;

IN: io.sockets.icmp.tests

[ { } ] [
    "localhost" <icmp> resolve-host
    [ [ icmp4? ] [ icmp6? ] bi or not ] filter
] unit-test

[ t ] [
    "127.0.0.1" <icmp4> <datagram>
    [ addr>> icmp4? ] with-disposal
] unit-test
