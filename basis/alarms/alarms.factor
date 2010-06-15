! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators.short-circuit fry
heaps init kernel math math.functions math.parser namespaces
quotations sequences system threads ;
IN: alarms

TUPLE: alarm
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

: set-next-alarm-time ( alarm -- alarm )
    ! start + delay + ceiling((now - (start + delay)) / interval) * interval
    nano-count 
    over start-nanos>> -
    over delay-nanos>> [ - ] when*
    over interval-nanos>> / ceiling
    over interval-nanos>> *
    over start-nanos>> +
    over delay-nanos>> [ + ] when*
    >>iteration-start-nanos ;

: stop-alarm? ( alarm -- ? )
    { [ thread>> self eq? not ] [ restart?>> ] } 1|| ;

DEFER: call-alarm-loop

: loop-alarm ( alarm -- )
    nano-count over
    [ iteration-start-nanos>> - ] [ interval-nanos>> ] bi <
    [ set-next-alarm-time ] dip
    [ dup iteration-start-nanos>> ] [ 0 ] if
    0 or sleep-until call-alarm-loop ;

: maybe-loop-alarm ( alarm -- )
    dup { [ stop-alarm? ] [ interval-nanos>> not ] } 1||
    [ drop ] [ loop-alarm ] if ;

: call-alarm-loop ( alarm -- )
    dup stop-alarm? [
        drop
    ] [
        [
            [ t >>quotation-running? drop ]
            [ quot>> call( -- ) ]
            [ f >>quotation-running? drop ] tri
        ] keep
        maybe-loop-alarm
    ] if ;

: sleep-delay ( alarm -- )
    dup stop-alarm? [
        drop
    ] [
        nano-count >>start-nanos
        delay-nanos>> [ sleep ] when*
    ] if ;

: alarm-loop ( alarm -- )
    [ sleep-delay ]
    [ nano-count >>iteration-start-nanos call-alarm-loop ]
    [ dup restart?>> [ f >>restart? alarm-loop ] [ drop ] if ] tri ;

PRIVATE>

: <alarm> ( quot delay-duration/f interval-duration/f -- alarm )
    alarm new
        swap >nanoseconds >>interval-nanos
        swap >nanoseconds >>delay-nanos
        swap >>quot ; inline

: start-alarm ( alarm -- )
    [
        '[ _ alarm-loop ] "Alarm execution" spawn
    ] keep thread<< ;

: stop-alarm ( alarm -- )
    dup quotation-running?>> [
        f >>thread drop
    ] [
        [ [ interrupt ] when* f ] change-thread drop
    ] if ;

: restart-alarm ( alarm -- )
    t >>restart?
    dup quotation-running?>> [
        drop
    ] [
        dup thread>> [ nip interrupt ] [ start-alarm ] if*
    ] if ;

<PRIVATE

: (start-alarm) ( quot start-duration interval-duration -- alarm )
    <alarm> [ start-alarm ] keep ;

PRIVATE>

: every ( quot interval-duration -- alarm )
    [ f ] dip (start-alarm) ;

: later ( quot delay-duration -- alarm )
    f (start-alarm) ;

: delayed-every ( quot duration -- alarm )
    dup (start-alarm) ;
