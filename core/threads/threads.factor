! Copyright (C) 2004, 2007 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays init hashtables io.backend kernel kernel.private
math namespaces queues sequences vectors io system sorting
continuations debugger ;

<PRIVATE

SYMBOL: sleep-queue

: sleep-time ( -- ms )
    sleep-queue get-global
    dup empty? [ drop 1000 ] [ first first millis [-] ] if ;

: run-queue ( -- queue ) \ run-queue get-global ;

: schedule-sleep ( ms continuation -- )
    2array global [
        sleep-queue [ swap add sort-keys ] change
    ] bind ;

: wake-up ( -- continuation )
    global [
        sleep-queue [ unclip second swap ] change
    ] bind ;

PRIVATE>

: schedule-thread ( continuation -- ) run-queue enque ;

: schedule-thread-with ( obj continuation -- )
    2array schedule-thread ;

: stop ( -- )
    walker-hook [
        f swap continue-with
    ] [
        run-queue deque dup array?
        [ first2 continue-with ] [ continue ] if
    ] if* ;

: yield ( -- ) [ schedule-thread stop ] callcc0 ;

: sleep ( ms -- )
    >fixnum millis + [ schedule-sleep stop ] callcc0 drop ;

: in-thread ( quot -- )
    [
        >r schedule-thread r> [
            V{ } set-catchstack
            { } set-retainstack
            [ print-error ] recover stop
        ] (throw)
    ] curry callcc0 ;

<PRIVATE

: (idle-thread) ( slow? -- )
    sleep-time dup zero?
    [ wake-up schedule-thread 2drop ]
    [ 0 ? io-multiplex ] if ;

: idle-thread ( -- )
    run-queue queue-empty? (idle-thread) yield idle-thread ;

: init-threads ( -- )
    <queue> \ run-queue set-global
    f sleep-queue set-global
    [ idle-thread ] in-thread ;

[ init-threads ] "threads" add-init-hook

PRIVATE>
