! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting io kernel
math strings sequences zeromq zeromq.ffi ;
IN: zeromq.examples.tasksink

: tasksink ( -- )
    [
        <zmq-context> &dispose
        ZMQ_PULL <zmq-socket> &dispose
        dup "tcp://*:5558" zmq-bind
        ! Wait for start of batch
        dup 0 zmq-recv drop
        ! Start our clock now
        now
        ! Process 100 confirmations
        100 <iota> [
            pick 0 zmq-recv drop
            10 rem zero? [ ":" ] [ "." ] if write flush
        ] each
        ! Calculate and report duration of batch
        ago duration>milliseconds "Total elapsed time: %d msec\n" printf
        drop
    ] with-destructors ;

MAIN: tasksink
