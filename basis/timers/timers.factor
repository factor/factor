! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators.short-circuit fry
heaps init kernel math math.functions math.parser namespaces
quotations sequences system threads ;
IN: timers

TUPLE: timer
    { quot callable initial: [ ] }
    start-nanos 
    delay-nanos
    interval-nanos
    iteration-start-nanos
    quotation-running?
    restart?
    thread ;

<PRIVATE

GENERIC: >nanoseconds ( obj -- duration/f )
M: f >nanoseconds ;
M: real >nanoseconds >integer ;
M: duration >nanoseconds duration>nanoseconds >integer ;

: set-next-timer-time ( timer -- timer )
    ! start + delay + ceiling((now - (start + delay)) / interval) * interval
    nano-count 
    over start-nanos>> -
    over delay-nanos>> [ - ] when*
    over interval-nanos>> / ceiling
    over interval-nanos>> *
    over start-nanos>> +
    over delay-nanos>> [ + ] when*
    >>iteration-start-nanos ;

: stop-timer? ( timer -- ? )
    { [ thread>> self eq? not ] [ restart?>> ] } 1|| ;

DEFER: call-timer-loop

: loop-timer ( timer -- )
    nano-count over
    [ iteration-start-nanos>> - ] [ interval-nanos>> ] bi <
    [ set-next-timer-time ] dip
    [ dup iteration-start-nanos>> ] [ 0 ] if
    0 or sleep-until call-timer-loop ;

: maybe-loop-timer ( timer -- )
    dup { [ stop-timer? ] [ interval-nanos>> not ] } 1||
    [ drop ] [ loop-timer ] if ;

: call-timer-loop ( timer -- )
    dup stop-timer? [
        drop
    ] [
        [
            [ t >>quotation-running? drop ]
            [ quot>> call( -- ) ]
            [ f >>quotation-running? drop ] tri
        ] keep
        maybe-loop-timer
    ] if ;

: sleep-delay ( timer -- )
    dup stop-timer? [
        drop
    ] [
        nano-count >>start-nanos
        delay-nanos>> [ sleep ] when*
    ] if ;

: timer-loop ( timer -- )
    [ sleep-delay ]
    [ nano-count >>iteration-start-nanos call-timer-loop ]
    [ dup restart?>> [ f >>restart? timer-loop ] [ drop ] if ] tri ;

PRIVATE>

: <timer> ( quot delay-duration/f interval-duration/f -- timer )
    timer new
        swap >nanoseconds >>interval-nanos
        swap >nanoseconds >>delay-nanos
        swap >>quot ; inline

: start-timer ( timer -- )
    [
        '[ _ timer-loop ] "Timer execution" spawn
    ] keep thread<< ;

: stop-timer ( timer -- )
    dup quotation-running?>> [
        f >>thread drop
    ] [
        [ [ interrupt ] when* f ] change-thread drop
    ] if ;

: restart-timer ( timer -- )
    t >>restart?
    dup quotation-running?>> [
        drop
    ] [
        dup thread>> [ nip interrupt ] [ start-timer ] if*
    ] if ;

<PRIVATE

: (start-timer) ( quot start-duration interval-duration -- timer )
    <timer> [ start-timer ] keep ;

PRIVATE>

: every ( quot interval-duration -- timer )
    [ f ] dip (start-timer) ;

: later ( quot delay-duration -- timer )
    f (start-timer) ;

: delayed-every ( quot duration -- timer )
    dup (start-timer) ;

: nanos-since ( nano-count -- nanos )
    [ nano-count ] dip - ;
