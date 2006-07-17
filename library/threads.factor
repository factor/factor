! Copyright (C) 2004, 2006 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays errors hashtables io-internals kernel math
namespaces queues sequences vectors ;

! Co-operative multitasker.

: run-queue ( -- queue ) \ run-queue get-global ;

: schedule-thread ( continuation -- ) run-queue enque ;

: sleep-queue ( -- vec ) \ sleep-queue get-global ;

: sleep-queue* ( -- vec )
    sleep-queue dup [ [ first ] 2apply swap - ] nsort ;

: sleep-time ( sorted-queue -- ms )
    dup empty? [ drop 1000 ] [ peek first millis [-] ] if ;

: stop ( -- ) run-queue deque continue ;

: yield ( -- ) [ schedule-thread stop ] callcc0 ;

: sleep ( ms -- )
    millis + [ 2array sleep-queue push stop ] callcc0 drop ;

: in-thread ( quot -- )
    [
        schedule-thread
        V{ } set-catchstack
        V{ } set-callstack
        V{ } set-retainstack
        try stop
    ] callcc0 drop ;

: (idle-thread) ( fast? -- )
    #! If fast, then we don't sleep, just select()
    sleep-queue* dup sleep-time dup zero?
    [ drop pop second schedule-thread drop ]
    [ nip 0 ? io-multiplex ] if ;

: idle-thread ( -- )
    #! This thread is always running.
    #! If run queue is not empty, we don't sleep.
    run-queue queue-empty? (idle-thread) yield idle-thread ;

: init-threads ( -- )
    <queue> \ run-queue set-global
    V{ } clone \ sleep-queue set-global ;
