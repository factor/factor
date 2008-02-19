! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel threads math concurrency.conditions
continuations ;
IN: concurrency.semaphores

TUPLE: semaphore count threads ;

: <semaphore> ( n -- semaphore )
    dup 0 < [ "Cannot have semaphore with negative count" throw ] when
    <dlist> semaphore construct-boa ;

: wait-to-acquire ( semaphore timeout -- )
    >r semaphore-threads r> "semaphore" wait ;

: acquire ( semaphore timeout -- )
    dup semaphore-count zero? [
        wait-to-acquire
    ] [
        drop
        dup semaphore-count 1- swap set-semaphore-count
    ] if ;

: release ( semaphore -- )
    dup semaphore-count 1+ over set-semaphore-count
    semaphore-threads notify-1 ;

: with-semaphore ( semaphore quot -- )
    over acquire [ release ] curry [ ] cleanup ; inline
