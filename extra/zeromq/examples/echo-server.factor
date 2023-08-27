! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: destructors io kernel strings zeromq zeromq.ffi ;

IN: zeromq.examples.echoserver

: echo-server ( -- )
    [
        <zmq-context> &dispose
        ZMQ_REP <zmq-socket> &dispose
        dup "tcp://127.0.0.1:5000" zmq-bind
        [
            dup 0 zmq-recv
            [ >string "Received " write print flush ]
            [ dupd 0 zmq-send ] bi
            t
        ] loop drop
    ] with-destructors ;

MAIN: echo-server
