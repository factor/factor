! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays command-line destructors formatting io kernel
math math.parser namespaces sequences splitting strings zeromq
zeromq.ffi ;
IN: zeromq.examples.wuclient

: wuclient ( -- )
    [
        <zmq-context> &dispose
        "Collecting updates from weather server…" print
        ZMQ_SUB <zmq-socket> &dispose
        dup "tcp://localhost:5556" zmq-connect
        command-line get [ "10001 " ] [ first ] if-empty
        2dup >byte-array ZMQ_SUBSCRIBE swap zmq-setopt
        0 100 dup [
            [ pick 0 zmq-recv
              >string split-words [ string>number ] map second +
            ] times
        ] dip
        / "Average temperature for zipcode '%s' was %dF\n" printf
        drop
    ] with-destructors ;

MAIN: wuclient

