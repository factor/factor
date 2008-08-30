! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel threads math concurrency.conditions
continuations accessors summary ;
IN: concurrency.semaphores

TUPLE: semaphore count threads ;

ERROR: negative-count-semaphore ;

M: negative-count-semaphore summary
    drop "Cannot have semaphore with negative count" ;

: <semaphore> ( n -- semaphore )
    dup 0 < [ negative-count-semaphore ] when
    <dlist> semaphore boa ;

: wait-to-acquire ( semaphore timeout -- )
    [ threads>> ] dip "semaphore" wait ;

: acquire-timeout ( semaphore timeout -- )
    over count>> zero?
    [ dupd wait-to-acquire ] [ drop ] if
    [ 1- ] change-count drop ;

: acquire ( semaphore -- )
    f acquire-timeout ;

: release ( semaphore -- )
    [ 1+ ] change-count
    threads>> notify-1 ;

: with-semaphore-timeout ( semaphore timeout quot -- )
    pick rot acquire-timeout swap
    [ release ] curry [ ] cleanup ; inline

: with-semaphore ( semaphore quot -- )
    over acquire swap [ release ] curry [ ] cleanup ; inline
