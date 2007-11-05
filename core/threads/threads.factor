! Copyright (C) 2004, 2007 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays init hashtables heaps io.backend kernel kernel.private
math namespaces queues sequences vectors io system sorting
continuations debugger ;

<PRIVATE

SYMBOL: sleep-queue

TUPLE: sleeping ms continuation ;

M: sleeping <=> ( obj1 obj2 -- n )
    [ sleeping-ms ] 2apply - ;

: sleep-time ( -- ms )
    sleep-queue get-global
    dup heap-empty? [ drop 1000 ] [ heap-peek sleeping-ms millis [-] ] if ;

: run-queue ( -- queue ) \ run-queue get-global ;

: schedule-sleep ( ms continuation -- )
    sleeping construct-boa sleep-queue get-global heap-push ;

: wake-up ( -- continuation )
    sleep-queue get-global heap-pop sleeping-continuation ;

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
            [ [ print-error ] recover stop ] call-clear
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
    <min-heap> sleep-queue set-global
    [ idle-thread ] in-thread ;

[ init-threads ] "threads" add-init-hook
PRIVATE>
