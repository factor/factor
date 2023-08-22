! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors io kernel strings
threads zeromq zeromq.ffi ;
IN: zeromq.examples.hwserver

: hwserver ( -- )
    [
        <zmq-context> &dispose
        ZMQ_REP <zmq-socket> &dispose
        dup "tcp://*:5555" zmq-bind
        [ t ] [
            dup
            [ 0 zmq-recv >string "Received " write print flush ]
            [ drop 1 seconds sleep ]
            [ "World" >byte-array 0 zmq-send ]
            tri
        ] while drop
    ] with-destructors ;

MAIN: hwserver
