! Copyright (C) 2012 Eungju PARK.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays calendar destructors formatting io kernel
math namespaces random threads zeromq zeromq.ffi ;
IN: zeromq.examples.taskvent

: taskvent ( -- )
    [
        <zmq-context> &dispose

        [
            ! Socket to send messages on
            ZMQ_PUSH <zmq-socket> &dispose
            dup "tcp://*:5557" zmq-bind
        ] [
            ! Socket to send start of batch message on
            ZMQ_PUSH <zmq-socket> &dispose
            dup "tcp://localhost:5558" zmq-connect
        ] bi

        "Press Enter when the workers are ready: " write flush
        read1 drop
        "Sending tasks to workers…\n" write flush

        ! The first message is "0" and signals start of batch
        dup "0" >byte-array 0 zmq-send

        ! Send 100 tasks
        0 100 [
            ! Random workload from 1 to 100msecs
            100 random 1 +
            dup [ + ] dip
            pickd "%d" sprintf >byte-array 0 zmq-send
        ] times
        "Total expected cost: %d msec\n" printf

        ! Give 0MQ time to deliver
        1 seconds sleep

        drop
        drop
    ] with-destructors ;

MAIN: taskvent
