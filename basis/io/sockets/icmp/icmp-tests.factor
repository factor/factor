
USING: accessors destructors kernel io.sockets io.sockets.icmp
sequences tools.test ;

IN: io.sockets.icmp.tests

[ { } ] [
    "localhost" <icmp> resolve-host
    [ [ icmp4? ] [ icmp6? ] bi or not ] filter
] unit-test
