! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data classes.struct
destructors io.binary io.sockets kernel libc locals sequences ;
IN: benchmark.echo

STRUCT: buffer { buf char[1024] } ;

:: send/recv ( packet server client buf -- )
    packet server addr>> client send
    1024 buf server receive-unsafe drop :> count
    packet buf count memcmp 0 assert= ; inline

: udp-echo ( -- )
    [
        { buffer } [| buf |
            10000 iota [ 4 >be ] map :> packets
            "127.0.0.1" 0 <inet4> <datagram> &dispose :> server
            "127.0.0.1" 0 <inet4> <datagram> &dispose :> client
            packets [ server client buf send/recv ] each
        ] with-scoped-allocation
    ] with-destructors ;

MAIN: udp-echo
