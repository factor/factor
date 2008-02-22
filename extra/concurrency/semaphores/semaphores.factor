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

: acquire-timeout ( semaphore timeout -- )
    over semaphore-count zero?
    [ dupd wait-to-acquire ] [ drop ] if
    dup semaphore-count 1- swap set-semaphore-count ;

: acquire ( semaphore -- )
    f acquire-timeout ;

: release ( semaphore -- )
    dup semaphore-count 1+ over set-semaphore-count
    semaphore-threads notify-1 ;

: with-semaphore-timeout ( semaphore timeout quot -- )
    pick rot acquire-timeout swap
    [ release ] curry [ ] cleanup ; inline

: with-semaphore ( semaphore quot -- )
    over acquire swap [ release ] curry [ ] cleanup ; inline
