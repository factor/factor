! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators.short-circuit fry
heaps init kernel math math.functions math.parser namespaces
quotations sequences system threads ;
IN: alarms

TUPLE: alarm
    { quot callable initial: [ ] }
    { start integer }
    interval
    { iteration-scheduled integer }
    { stop? boolean } ;

SYMBOL: alarms
SYMBOL: alarm-thread

: cancel-alarm ( alarm -- ) t >>stop? drop ;

<PRIVATE

: notify-alarm-thread ( -- )
    alarm-thread get-global interrupt ;

GENERIC: >nanoseconds ( obj -- duration/f )
M: f >nanoseconds ;
M: real >nanoseconds >integer ;
M: duration >nanoseconds duration>nanoseconds >integer ;

: <alarm> ( quot start interval -- alarm )
    alarm new
        swap >nanoseconds >>interval
        nano-count >>start
        swap >nanoseconds over start>> + >>iteration-scheduled
        swap >>quot ; inline

: register-alarm ( alarm -- )
    dup iteration-scheduled>> alarms get-global heap-push* drop
    notify-alarm-thread ;

: alarm-expired? ( alarm n -- ? )
    [ start>> ] dip <= ;

: set-next-alarm-time ( alarm -- alarm )
    ! start + ceiling((now - start) / interval) * interval
    nano-count 
    over start>> -
    over interval>> / ceiling
    over interval>> *
    over start>> + >>iteration-scheduled ; inline

DEFER: call-alarm-loop

: loop-alarm ( alarm -- )
    nano-count over
    [ iteration-scheduled>> - ] [ interval>> ] bi <
    [ set-next-alarm-time ] dip [
        [ iteration-scheduled>> sleep-until ]
        [ call-alarm-loop ] bi
    ] [
        0 sleep-until call-alarm-loop
    ] if ;

: maybe-loop-alarm ( alarm -- )
    dup { [ stop?>> ] [ interval>> not ] } 1||
    [ drop ] [ loop-alarm ] if ;

: call-alarm-loop ( alarm -- )
    dup stop?>> [
        drop
    ] [
        [
            [ ] [ quot>> ] bi call( obj -- )
        ] keep maybe-loop-alarm
    ] if ;

: call-alarm ( alarm -- )
    '[ _ call-alarm-loop ] "Alarm execution" spawn drop ;

: (trigger-alarms) ( alarms n -- )
    over heap-empty? [
        2drop
    ] [
        over heap-peek drop over alarm-expired? [
            over heap-pop drop call-alarm (trigger-alarms)
        ] [
            2drop
        ] if
    ] if ;

: trigger-alarms ( alarms -- )
    nano-count (trigger-alarms) ;

: next-alarm ( alarms -- nanos/f )
    dup heap-empty? [ drop f ] [ heap-peek drop start>> ] if ;

: alarm-thread-loop ( -- )
    alarms get-global
    dup next-alarm sleep-until
    trigger-alarms ;

: cancel-alarms ( alarms -- )
    [
        heap-pop-all [ nip t >>stop? drop ] assoc-each
    ] when* ;

: init-alarms ( -- )
    alarms [ cancel-alarms <min-heap> ] change-global
    [ alarm-thread-loop t ] "Alarms" spawn-server
    alarm-thread set-global ;

[ init-alarms ] "alarms" add-startup-hook

: drop-alarm ( quot duration -- quot' duration )
    [ [ drop ] prepose ] dip ; inline

PRIVATE>

: add-alarm ( quot start interval -- alarm )
    <alarm> [ register-alarm ] keep ;

: later* ( quot: ( alarm -- ) duration -- alarm ) f add-alarm ;

: later ( quot: ( -- ) duration -- alarm ) drop-alarm later* ;

: every* ( quot: ( alarm -- ) duration -- alarm ) dup add-alarm ;

: every ( quot: ( -- ) duration -- alarm ) drop-alarm every* ;
