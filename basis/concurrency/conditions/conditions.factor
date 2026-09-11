! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar deques dlists kernel
math math.order system threads timers ;
IN: concurrency.conditions

! Keep one deadline across predicate rechecks and unrelated wakeups.
TUPLE: deadline nanos ;
GENERIC: >deadline ( timeout -- deadline/f )
M: f >deadline ;
M: deadline >deadline ;
M: real >deadline nano-count + deadline boa ;
M: duration >deadline duration>nanoseconds >deadline ;

: remaining-timeout ( timeout -- timeout' )
    dup deadline? [ nanos>> nano-count - 0 max ] when ;

: notify-1 ( deque -- )
    dup deque-empty? [ drop ] [ pop-back resume-now ] if ; inline

: notify-all ( deque -- )
    [ resume-now ] slurp-deque ; inline

: queue-timeout ( queue timeout -- timer )
    ! Add an timer which removes the current thread from the
    ! queue, and resumes it, passing it a value of t.
    [
        [ self swap push-front* ] keep '[
            _ _
            [ delete-node ] [ drop node-value ] 2bi
            t swap resume-with
        ]
    ] dip remaining-timeout later ;

ERROR: timed-out-error timer ;

: queue ( queue -- )
    [ self ] dip push-front ; inline

: wait ( queue timeout status -- )
    over [
        [ queue-timeout ] dip suspend
        [ timed-out-error ] [ stop-timer ] if
    ] [
        [ drop queue ] dip suspend drop
    ] if ; inline
