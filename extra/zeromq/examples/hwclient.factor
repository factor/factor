! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays destructors formatting io kernel sequences
strings zeromq zeromq.ffi ;
IN: zeromq.examples.hwclient

: hwclient ( -- )
    [
        <zmq-context> &dispose
        "Connecting to hello world server…" print
        ZMQ_REQ <zmq-socket> &dispose
        dup "tcp://localhost:5555" zmq-connect
        10 <iota> [
            [ "Hello" dup rot "Sending %s %d...\n" printf
              dupd >byte-array 0 zmq-send ]
            [ [ dup 0 zmq-recv >string ] dip
              "Received %s %d\n" printf flush ]
            bi
        ] each drop
    ] with-destructors ;

MAIN: hwclient

