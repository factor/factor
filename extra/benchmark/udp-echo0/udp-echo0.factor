! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors destructors fry io.binary io.sockets kernel
sequences ;

IN: benchmark.udp-echo0

: send/recv ( packet server client -- )
    [ over over addr>> ] [ send ] bi* receive drop assert= ;

: udp-echo ( #times #bytes -- )
    '[
        _ iota [ _ >be ] map
        "127.0.0.1" 0 <inet4> <datagram>
        "127.0.0.1" 0 <inet4> <datagram>
        [ send/recv ] 2curry each
    ] with-destructors ;


: udp-echo0 ( -- ) 50,000 1 udp-echo ;

MAIN: udp-echo0
