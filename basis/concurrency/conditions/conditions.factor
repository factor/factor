! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar deques dlists kernel
locals math math.order system threads timers ;
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

TUPLE: condition-waiter thread notified? ;

GENERIC: notify-waiter ( waiter -- )
M: thread notify-waiter resume-now ;
M: condition-waiter notify-waiter
    t >>notified? thread>> resume-now ;

: notify-1 ( deque -- )
    dup deque-empty? [ drop ] [ pop-back notify-waiter ] if ; inline

: notify-all ( deque -- )
    [ notify-waiter ] slurp-deque ; inline

:: queue-timeout ( queue timeout -- timer )
    self f condition-waiter boa :> waiter
    waiter queue push-front* :> node
    [
        waiter notified?>> [
            t waiter notified?<<
            node queue delete-node
            t waiter thread>> resume-with
        ] unless
    ] timeout remaining-timeout later ;

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
