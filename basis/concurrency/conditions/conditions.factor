! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: deques kernel threads timers ;
IN: concurrency.conditions

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
    ] dip later ;

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
