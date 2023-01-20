! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors calendar kernel math quotations system threads ;

IN: timers

TUPLE: timer
    { quot callable initial: [ ] }
    delay-nanos
    interval-nanos
    next-nanos
    quotation-running?
    thread ;

<PRIVATE

GENERIC: >nanoseconds ( obj -- duration/f )
M: f >nanoseconds ;
M: real >nanoseconds >integer ;
M: duration >nanoseconds duration>nanoseconds >integer ;

: delay-nanos ( timer -- n )
    delay-nanos>> 0 or nano-count + ;

: interval-nanos ( timer -- n/f )
    [ next-nanos>> nano-count over - ] [ interval-nanos>> ] bi
    [ dupd [ mod ] [ swap - ] bi + + ] [ 2drop f ] if* ;

: next-nanos ( timer -- timer n/f )
    dup thread>> self eq? [ dup next-nanos>> ] [ f ] if ;

: run-timer ( timer -- timer )
    dup interval-nanos >>next-nanos
    t >>quotation-running?
    dup quot>> call( -- )
    f >>quotation-running? ;

: timer-loop ( timer -- )
    [ next-nanos ] [
        dup nano-count <= [
            drop run-timer yield
        ] [
            sleep-until
        ] if
    ] while* dup thread>> self eq? [ f >>thread ] when drop ;

: ?interrupt ( thread timer -- )
    quotation-running?>> [ drop ] [ [ interrupt ] when* ] if ;

PRIVATE>

ERROR: timer-already-started timer ;

: <timer> ( quot delay-duration/f interval-duration/f -- timer )
    timer new
        swap >nanoseconds >>interval-nanos
        swap >nanoseconds >>delay-nanos
        swap >>quot ; inline

: start-timer ( timer -- )
    dup thread>> [ timer-already-started ] when
    dup delay-nanos >>next-nanos
    dup '[ _ timer-loop ] "Timer" <thread>
    [ >>thread drop ] [ (spawn) ] bi ;

: stop-timer ( timer -- )
    [ f ] change-thread ?interrupt ;

: restart-timer ( timer -- )
    dup thread>> [
        dup delay-nanos >>next-nanos
        [ thread>> ] [ ?interrupt ] bi
    ] [
        start-timer
    ] if ;

<PRIVATE

: (start-timer) ( quot start-duration interval-duration -- timer )
    <timer> [ start-timer ] keep ; inline

PRIVATE>

: every ( quot interval-duration -- timer )
    f swap (start-timer) ;

: later ( quot delay-duration -- timer )
    f (start-timer) ;

: delayed-every ( quot duration -- timer )
    dup (start-timer) ;
