! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.conditions continuations dlists
kernel math summary ;
IN: concurrency.semaphores

TUPLE: semaphore count threads ;

: <semaphore> ( n -- semaphore )
    assert-non-negative <dlist> semaphore boa ;

: wait-to-acquire ( semaphore timeout -- )
    [ threads>> ] dip "semaphore" wait ;

: acquire-timeout ( semaphore timeout -- )
    over count>> zero?
    [ dupd wait-to-acquire ] [ drop ] if
    [ 1 - ] change-count drop ;

: acquire ( semaphore -- )
    f acquire-timeout ;

: release ( semaphore -- )
    [ 1 + ] change-count
    threads>> notify-1 ;

:: with-semaphore-timeout ( semaphore timeout quot -- )
    semaphore timeout acquire-timeout
    quot [ semaphore release ] finally ; inline

: with-semaphore ( semaphore quot -- )
    swap dup acquire '[ _ release ] finally ; inline
