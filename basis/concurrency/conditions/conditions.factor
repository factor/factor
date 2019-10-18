! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: deques threads kernel arrays sequences alarms fry ;
IN: concurrency.conditions

: notify-1 ( deque -- )
    dup deque-empty? [ drop ] [ pop-back resume-now ] if ;

: notify-all ( deque -- )
    [ resume-now ] slurp-deque ;

: queue-timeout ( queue timeout -- alarm )
    #! Add an alarm which removes the current thread from the
    #! queue, and resumes it, passing it a value of t.
    [
        [ self swap push-front* ] keep '[
            _ _
            [ delete-node ] [ drop node-value ] 2bi
            t swap resume-with
        ]
    ] dip later ;

ERROR: wait-timeout ;

: wait ( queue timeout status -- )
    over [
        [ queue-timeout [ drop ] ] dip suspend
        [ wait-timeout ] [ cancel-alarm ] if
    ] [
        [ drop '[ _ push-front ] ] dip suspend drop
    ] if ;
