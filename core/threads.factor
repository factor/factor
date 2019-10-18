! Copyright (C) 2004, 2007 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays errors hashtables io-internals kernel math
namespaces queues sequences vectors ;

! Co-operative multitasker.

: run-queue ( -- queue ) \ run-queue get-global ;

: schedule-thread ( continuation -- ) run-queue enque ;

: schedule-thread-with ( obj continuation -- )
    2array schedule-thread ;

SYMBOL: sleep-queue

: sleep-time ( -- ms )
    sleep-queue get-global
    dup empty? [ drop 1000 ] [ first first millis [-] ] if ;

: stop ( -- )
    walker-hook [
        f swap continue-with
    ] [
        run-queue deque dup array?
        [ first2 continue-with ] [ continue ] if
    ] if* ;

: yield ( -- ) [ schedule-thread stop ] callcc0 ;

: (sleep) ( ms continuation -- )
    2array global [
        sleep-queue [ swap add sort-keys ] change
    ] bind ;

: wake-up ( -- continuation )
    global [
        sleep-queue [ unclip second swap ] change
    ] bind ;

: sleep ( ms -- )
    >fixnum millis + [ (sleep) stop ] callcc0 drop ;

: in-thread ( quot -- )
    [
        schedule-thread
        V{ } set-catchstack
        V{ } set-callstack
        V{ } set-retainstack
        [ print-error ] recover
        stop
    ] callcc0 drop ;

IN: kernel-internals

: (idle-thread) ( slow? -- )
    sleep-time dup zero?
    [ wake-up schedule-thread 2drop ]
    [ 0 ? io-multiplex ] if ;

: idle-thread ( -- )
    #! This thread is always running.
    #! If run queue is not empty, we don't sleep.
    run-queue queue-empty? (idle-thread) yield idle-thread ;

: init-threads ( -- )
    <queue> \ run-queue set-global
    f sleep-queue set-global
    [ idle-thread ] in-thread ;
