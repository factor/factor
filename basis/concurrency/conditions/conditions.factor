! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dequeues threads kernel arrays sequences alarms ;
IN: concurrency.conditions

: notify-1 ( dequeue -- )
    dup dequeue-empty? [ drop ] [ pop-back resume-now ] if ;

: notify-all ( dequeue -- )
    [ resume-now ] slurp-dequeue ;

: queue-timeout ( queue timeout -- alarm )
    #! Add an alarm which removes the current thread from the
    #! queue, and resumes it, passing it a value of t.
    >r [ self swap push-front* ] keep [
        [ delete-node ] [ drop node-value ] 2bi
        t swap resume-with
    ] 2curry r> later ;

: wait ( queue timeout status -- )
    over [
        >r queue-timeout [ drop ] r> suspend
        [ "Timeout" throw ] [ cancel-alarm ] if
    ] [
        >r drop [ push-front ] curry r> suspend drop
    ] if ;
