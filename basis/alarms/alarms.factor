! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs boxes calendar
combinators.short-circuit fry heaps init kernel math.order
namespaces quotations threads math monotonic-clock ;
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

: normalize-argument ( obj -- nanoseconds )
    >duration duration>nanoseconds >integer ;

: <alarm> ( quot start interval -- alarm )
    alarm new
        swap dup [ normalize-argument ] when >>interval
        swap dup [ normalize-argument monotonic-count + ] when >>start
        swap >>quot
        <box> >>entry ;

: register-alarm ( alarm -- )
    [ dup start>> alarms get-global heap-push* ]
    [ entry>> >box ] bi
    notify-alarm-thread ;

: alarm-expired? ( alarm n -- ? )
    [ start>> ] dip <= ;

: reschedule-alarm ( alarm -- )
    dup interval>> monotonic-count + >>start register-alarm ;

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
    monotonic-count (trigger-alarms) ;

: next-alarm ( alarms -- timestamp/f )
    dup heap-empty? [ drop f ] [
        heap-peek drop start>>
        monotonic-count swap -
        nanoseconds hence
    ] if ;

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
