! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors destructors endian io.sockets kernel
sequences ;

IN: benchmark.udp-echo0

: send/recv ( packet server client -- )
    [ 2dup addr>> ] [ send ] bi* receive drop assert= ;

: udp-echo ( #times #bytes -- )
    '[
        _ <iota> [ _ >be ] map
        "127.0.0.1" 0 <inet4> <datagram> &dispose
        "127.0.0.1" 0 <inet4> <datagram> &dispose
        [ send/recv ] 2curry each
    ] with-destructors ;


: udp-echo0-benchmark ( -- ) 10,000 1 udp-echo ;

MAIN: udp-echo0-benchmark
