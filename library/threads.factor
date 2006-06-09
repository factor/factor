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

DEFER: next-thread

: do-sleep ( -- continuation )
    sleep-queue* dup sleep-time dup zero?
    [ drop pop second ] [ nip io-multiplex next-thread ] if ;

: next-thread ( -- continuation )
    run-queue dup queue-empty? [ drop do-sleep ] [ deque ] if ;

: stop ( -- ) next-thread continue ;

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

: init-threads ( -- )
    global [
        <queue> \ run-queue set
        V{ } clone \ sleep-queue set
    ] bind ;
