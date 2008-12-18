! Based on http://research.sun.com/people/mario/java_benchmarking/
! Ported by Factor by Slava Pestov
!
! Based on original version written in BCPL by Dr Martin Richards
! in 1981 at Cambridge University Computer Laboratory, England
! Java version:  Copyright (C) 1995 Sun Microsystems, Inc.
! by Jonathan Gibbons.
! Outer loop added 8/7/96 by Alex Jacoby
USING: values kernel accessors math math.bitwise sequences
arrays combinators fry locals ;
IN: benchmark.richards

! Packets
TUPLE: packet link id kind a1 a2 ;

: BUFSIZE 4 ; inline

: <packet> ( link id kind -- packet )
    packet new
        swap >>kind
        swap >>id
        swap >>link
        0 >>a1
        BUFSIZE 0 <array> >>a2 ;

: last-packet ( packet -- last )
    dup link>> [ last-packet ] [ ] ?if ;

: append-to ( packet list -- packet )
    [ f >>link ] dip
    [ tuck last-packet >>link drop ] when* ;

! Tasks
: I_IDLE 1 ; inline
: I_WORK 2 ; inline
: I_HANDLERA 3 ; inline
: I_HANDLERB 4 ; inline
: I_DEVA 5 ; inline
: I_DEVB 6 ; inline

! Packet types
: K_DEV 1000 ; inline
: K_WORK 1001 ; inline

: PKTBIT 1 ; inline
: WAITBIT 2 ; inline
: HOLDBIT 4 ; inline

: S_RUN 0 ;  inline
: S_RUNPKT ( -- n ) { PKTBIT } flags ; inline
: S_WAIT ( -- n ) { WAITBIT } flags ; inline
: S_WAITPKT ( -- n ) { WAITBIT PKTBIT } flags ; inline
: S_HOLD ( -- n ) { HOLDBIT } flags ; inline
: S_HOLDPKT ( -- n ) { HOLDBIT PKTBIT } flags ; inline
: S_HOLDWAIT ( -- n ) { HOLDBIT WAITBIT } flags ; inline
: S_HOLDWAITPKT ( -- n ) { HOLDBIT WAITBIT PKTBIT } flags ; inline

: task-tab-size 10 ; inline

VALUE: task-tab
VALUE: task-list
VALUE: tracing
VALUE: hold-count
VALUE: qpkt-count

TUPLE: task link id pri wkq state ;

: new-task ( id pri wkq state class -- task )
    new
        swap >>state
        swap >>wkq
        swap >>pri
        swap >>id
        task-list >>link
        dup to: task-list
        dup dup id>> task-tab set-nth ; inline

GENERIC: fn ( packet task -- task )

: state-on ( task flag -- task )
    '[ _ bitor ] change-state ; inline

: state-off ( task flag -- task )
    '[ _ bitnot bitand ] change-state ; inline

: wait-task ( task -- task )
    WAITBIT state-on ;

: hold ( task -- task )
    hold-count 1+ to: hold-count
    HOLDBIT state-on
    link>> ;

: highest-priority ( t1 t2 -- t1/t2 )
    [ [ pri>> ] bi@ > ] most ;

: find-tcb ( i -- task )
    task-tab nth [ "Bad task" throw ] unless* ;

: release ( task i -- task )
    find-tcb HOLDBIT state-off highest-priority ;

:: qpkt ( task pkt -- task )
    [let | t [ pkt id>> find-tcb ] |
        t [
            qpkt-count 1+ to: qpkt-count
            f pkt (>>link)
            task id>> pkt (>>id)
            t wkq>> [
                pkt t wkq>> append-to t (>>wkq)
                task
            ] [
                pkt t (>>wkq)
                t PKTBIT state-on drop
                t task highest-priority
            ] if
        ] [ task ] if
    ] ;

: schedule-waitpkt ( task -- task pkt )
    dup wkq>>
    2dup link>> >>wkq drop
    2dup S_RUNPKT S_RUN ? >>state drop ; inline

: schedule-run ( task pkt -- task )
    swap fn ; inline

: schedule-wait ( task -- task )
    link>> ; inline

: (schedule) ( task -- )
    [
        dup state>> {
            { S_WAITPKT [ schedule-waitpkt schedule-run (schedule) ] }
            { S_RUN [ f schedule-run (schedule) ] }
            { S_RUNPKT [ f schedule-run (schedule) ] }
            { S_WAIT [ schedule-wait (schedule) ] }
            { S_HOLD [ schedule-wait (schedule) ] }
            { S_HOLDPKT [ schedule-wait (schedule) ] }
            { S_HOLDWAIT [ schedule-wait (schedule) ] }
            { S_HOLDWAITPKT [ schedule-wait (schedule) ] }
            [ 2drop ]
        } case
    ] when* ;

: schedule ( -- )
    task-list (schedule) ;

! Device task
TUPLE: device-task < task v1 ;

: <device-task> ( id pri wkq -- task )
    dup S_WAITPKT S_WAIT ? device-task new-task ;

M:: device-task fn ( pkt task -- task )
    pkt [
        task dup v1>>
        [ wait-task ]
        [ [ f ] change-v1 swap qpkt ] if
    ] [ pkt task (>>v1) task hold ] if ;

TUPLE: handler-task < task workpkts devpkts ;

: <handler-task> ( id pri wkq -- task )
    dup S_WAITPKT S_WAIT ? handler-task new-task ;

M:: handler-task fn ( pkt task -- task )
    pkt [
        task over kind>> K_WORK =
        [ [ append-to ] change-workpkts ]
        [ [ append-to ] change-devpkts ]
        if drop
    ] when*

    task workpkts>> [
        [let* | devpkt [ task devpkts>> ]
                workpkt [ task workpkts>> ]
                count [ workpkt a1>> ] |
            count BUFSIZE > [
                workpkt link>> task (>>workpkts)
                task workpkt qpkt
            ] [
                devpkt [
                    devpkt link>> task (>>devpkts)
                    count workpkt a2>> nth devpkt (>>a1)
                    count 1+ workpkt (>>a1)
                    task devpkt qpkt
                ] [
                    task wait-task
                ] if
            ] if
        ]
    ] [ task wait-task ] if ;

! Idle task
TUPLE: idle-task < task { v1 fixnum } { v2 fixnum } ;

: <idle-task> ( i a1 a2 -- task )
    [ 0 f S_RUN idle-task new-task ] 2dip
    [ >>v1 ] [ >>v2 ] bi* ;

M: idle-task fn ( pkt task -- task )
    nip
    [ 1- ] change-v2
    dup v2>> 0 = [ hold ] [
        dup v1>> 1 bitand 0 = [
            [ -1 shift ] change-v1
            I_DEVA release
        ] [
            [ -1 shift HEX: d008 bitor ] change-v1
            I_DEVB release
        ] if
    ] if ;

! Work task
TUPLE: work-task < task { handler fixnum } { n fixnum } ;

: <work-task> ( id pri w -- work-task )
    dup S_WAITPKT S_WAIT ? work-task new-task
    I_HANDLERA >>handler
    0 >>n ;

M:: work-task fn ( pkt task -- task )
    pkt [
        task [ I_HANDLERA = I_HANDLERB I_HANDLERA ? ] change-handler drop
        task handler>> pkt (>>id)
        0 pkt (>>a1)
        BUFSIZE [| i |
            task [ 1+ ] change-n drop
            task n>> 26 > [ 1 task (>>n) ] when
            task n>> 1 - CHAR: A + i pkt a2>> set-nth
        ] each
        task pkt qpkt
    ] [ task wait-task ] if ;

! Main
: init ( -- )
    task-tab-size f <array> to: task-tab
    f to: tracing
    0 to: hold-count
    0 to: qpkt-count ;

: start ( -- )
    I_IDLE 1 10000 <idle-task> drop

    I_WORK 1000
    f 0 K_WORK <packet> 0 K_WORK <packet>
    <work-task> drop

    I_HANDLERA 2000
    f I_DEVA K_DEV <packet>
    I_DEVA K_DEV <packet>
    I_DEVA K_DEV <packet>
    <handler-task> drop

    I_HANDLERB 3000
    f I_DEVB K_DEV <packet>
    I_DEVB K_DEV <packet>
    I_DEVB K_DEV <packet>
    <handler-task> drop

    I_DEVA 4000 f <device-task> drop
    I_DEVB 4000 f <device-task> drop ;

: check ( -- )
    qpkt-count 23246 assert=
    hold-count 9297 assert= ;

: run ( -- )
    init
    start
    schedule check ;
