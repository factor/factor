! Copyright (C) 2013 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors io kernel present strings
threads zeromq zeromq.ffi ;
IN: zeromq.examples.echo-client

: echo-client ( -- )
    [
        <zmq-context> &dispose
        ZMQ_REQ <zmq-socket> &dispose
        dup "tcp://127.0.0.1:5000" zmq-connect
        [
            now present
            [ "Sending " write print flush ]
            [ >byte-array dupd 0 zmq-send ] bi
            dup 0 zmq-recv >string
            "Received " write print flush
            1 seconds sleep
            t
        ] loop drop
    ] with-destructors ;

MAIN: echo-client
