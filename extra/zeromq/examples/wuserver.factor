! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting kernel math
namespaces random zeromq zeromq.ffi ;
IN: zeromq.examples.wuserver

: wuserver ( -- )
    [
        <zmq-context> &dispose
        ZMQ_PUB <zmq-socket> &dispose
        dup "tcp://*:5556" zmq-bind
        dup "ipc://weather.ipc" zmq-bind

        [
            dup
            100000 random
            215 random 80 -
            50 random 10 +
            "%05d %d %d" sprintf
            >byte-array 0 zmq-send
            t
        ] loop

        drop
    ] with-destructors ;

MAIN: wuserver
