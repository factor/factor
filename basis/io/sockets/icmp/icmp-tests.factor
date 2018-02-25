
USING: accessors destructors kernel io.sockets io.sockets.icmp
sequences tools.test ;

{ { } } [
    "localhost" <icmp> resolve-host
    [ [ icmp4? ] [ icmp6? ] bi or ] reject
] unit-test
