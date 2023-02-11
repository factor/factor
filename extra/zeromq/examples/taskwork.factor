! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting io kernel
math.parser strings threads zeromq zeromq.ffi ;
IN: zeromq.examples.taskwork

: taskwork ( -- )
    [
        <zmq-context> &dispose

        [
            ! Socket to receive messages on
            ZMQ_PULL <zmq-socket> &dispose
            dup "tcp://localhost:5557" zmq-connect
        ] [
            ! Socket to send messages to
            ZMQ_PUSH <zmq-socket> &dispose
            dup "tcp://localhost:5558" zmq-connect
        ] bi

        ! Process tasks forever
        [
            over 0 zmq-recv >string
            ! Simple progress indicator for the viewer
            dup "%s." printf flush
            ! Do the work
            string>number milliseconds sleep
            ! Send results to sink
            dup "" >byte-array 0 zmq-send
            t
        ] loop

        drop
        drop
    ] with-destructors ;

MAIN: taskwork
