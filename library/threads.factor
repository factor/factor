! Copyright (C) 2004, 2005 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: threads
USING: errors hashtables io-internals kernel lists math
namespaces queues sequences vectors ;

! Co-operative multitasker.

: run-queue ( -- queue ) \ run-queue global hash ;

: schedule-thread ( continuation -- ) run-queue enque ;

: sleep-queue ( -- vec ) \ sleep-queue global hash ;

: sleep-queue* ( -- vec )
    sleep-queue dup [ 2car swap - ] nsort ;

: sleep-time ( sorted-queue -- ms )
    dup empty? [ drop -1 ] [ peek car millis - 0 max ] if ;

DEFER: next-thread

: do-sleep ( -- continuation )
    sleep-queue* dup sleep-time dup 0 =
    [ drop pop cdr ] [ nip io-multiplex next-thread ] if ;

: next-thread ( -- continuation )
    run-queue dup queue-empty? [ drop do-sleep ] [ deque ] if ;

: stop ( -- ) next-thread continue ;

: yield ( -- ) [ schedule-thread stop ] callcc0 ;

: sleep ( ms -- )
    millis + [ cons sleep-queue push stop ] callcc0 drop ;

: in-thread ( quot -- )
    [
        schedule-thread
        V{ } set-catchstack V{ } set-callstack
        try stop
    ] callcc0 drop ;

TUPLE: timer object delay last ;

: timer-now millis swap set-timer-last ;

C: timer ( object delay -- timer )
    [ set-timer-delay ] keep
    [ set-timer-object ] keep
    dup timer-now ;

GENERIC: tick ( ms object -- )

: timers ( -- hash ) \ timers global hash ;

: add-timer ( object delay -- )
    over >r <timer> r> timers set-hash ;

: remove-timer ( object -- ) timers remove-hash ;

: restart-timer ( object -- )
    timers hash [ timer-now ] when* ;

: next-time ( timer -- ms ) dup timer-delay swap timer-last + ;

: advance-timer ( ms timer -- delay )
    #! Outputs the time since the last firing.
    [ timer-last - 0 max ] 2keep set-timer-last ;

: do-timer ( ms timer -- )
    #! Takes current time, and a timer. If the timer is set to
    #! fire, calls its callback.
    dup next-time pick <= [
        [ advance-timer ] keep timer-object tick
    ] [
        2drop
    ] if ;

: do-timers ( -- )
    millis timers hash-values [ do-timer ] each-with ;

: init-threads ( -- )
    global [
        <queue> \ run-queue set
        V{ } clone \ sleep-queue set
        H{ } clone \ timers set
    ] bind ;
