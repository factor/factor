IN: concurrency.semaphores

TUPLE: semaphore count threads ;

: <semaphore> ( -- semaphore )
    0 <dlist> semaphore construct-boa ;

: wait-to-acquire ( semaphore -- )
    [ semaphore-threads push-front ] suspend drop ;

: acquire ( semaphore -- )
    dup semaphore-count zero? [
        wait-to-acquire
    ] [
        dup semaphore-count 1- swap set-semaphore-count
    ] if ;

: release ( semaphore -- )
    dup semaphore-count 1+ over set-semaphore-count
    semaphore-threads notify-1 ;
