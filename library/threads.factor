! Copyright (C) 2004, 2005 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: threads
USING: errors hashtables io-internals kernel lists math
namespaces queues sequences vectors ;

! Co-operative multitasker.

: run-queue ( -- queue ) \ run-queue global hash ;

: schedule-thread ( quot -- ) run-queue enque ;

: sleep-queue ( -- vec ) \ sleep-queue global hash ;

: sleep-queue* ( -- vec )
    sleep-queue dup [ 2car swap - ] nsort ;

: sleep-time ( sorted-queue -- ms )
    dup empty? [ drop -1 ] [ peek car millis - 0 max ] ifte ;

DEFER: next-thread

: do-sleep ( -- quot )
    sleep-queue* dup sleep-time dup 0 =
    [ drop pop ] [ io-multiplex next-thread ] ifte ;

: next-thread ( -- quot )
    run-queue dup queue-empty? [ drop do-sleep ] [ deque ] ifte ;

: stop ( -- ) next-thread call ;

: yield ( -- ) [ schedule-thread stop ] callcc0 ;

: sleep ( ms -- )
    millis + [ cons sleep-queue push stop ] callcc0 drop ;

: in-thread ( quot -- )
    [
        schedule-thread
        [ ] set-catchstack { } set-callstack
        try stop
    ] callcc0 drop ;

: init-threads ( -- )
    global [
        <queue> \ run-queue set
        10 <vector> \ sleep-queue set
    ] bind ;
