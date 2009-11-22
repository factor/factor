! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs boxes calendar
combinators.short-circuit fry heaps init kernel math.order
namespaces quotations threads math system ;
IN: alarms

TUPLE: alarm
    { quot callable initial: [ ] }
    { start integer }
    interval
    { entry box } ;

<PRIVATE

SYMBOL: alarms
SYMBOL: alarm-thread

: notify-alarm-thread ( -- )
    alarm-thread get-global interrupt ;

GENERIC: >nanoseconds ( obj -- duration/f )
M: f >nanoseconds ;
M: real >nanoseconds >integer ;
M: duration >nanoseconds duration>nanoseconds >integer ;

: <alarm> ( quot start interval -- alarm )
    alarm new
        swap >nanoseconds >>interval
        swap >nanoseconds nano-count + >>start
        swap >>quot
        <box> >>entry ;

: register-alarm ( alarm -- )
    [ dup start>> alarms get-global heap-push* ]
    [ entry>> >box ] bi
    notify-alarm-thread ;

: alarm-expired? ( alarm n -- ? )
    [ start>> ] dip <= ;

: reschedule-alarm ( alarm -- )
    dup interval>> nano-count + >>start register-alarm ;

: call-alarm ( alarm -- )
    [ entry>> box> drop ]
    [ dup interval>> [ reschedule-alarm ] [ drop ] if ]
    [ quot>> "Alarm execution" spawn drop ] tri ;

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
        heap-pop-all [ nip entry>> box> drop ] assoc-each
    ] when* ;

: init-alarms ( -- )
    alarms [ cancel-alarms <min-heap> ] change-global
    [ alarm-thread-loop t ] "Alarms" spawn-server
    alarm-thread set-global ;

[ init-alarms ] "alarms" add-startup-hook

PRIVATE>

: add-alarm ( quot start interval -- alarm )
    <alarm> [ register-alarm ] keep ;

: later ( quot duration -- alarm ) f add-alarm ;

: every ( quot duration -- alarm ) dup add-alarm ;

: cancel-alarm ( alarm -- )
    entry>> [ alarms get-global heap-delete ] if-box? ;
