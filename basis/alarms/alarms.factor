! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators generic init
kernel math namespaces sequences heaps boxes threads
quotations assocs math.order ;
IN: alarms

TUPLE: alarm
    { quot callable initial: [ ] }
    { time timestamp }
    interval
    { entry box } ;

<PRIVATE

SYMBOL: alarms
SYMBOL: alarm-thread

: notify-alarm-thread ( -- )
    alarm-thread get-global interrupt ;

ERROR: bad-alarm-frequency frequency ;
: check-alarm ( frequency/f -- frequency/f )
    dup [ duration? ] [ not ] bi or [ bad-alarm-frequency ] unless ;

: <alarm> ( quot time frequency -- alarm )
    check-alarm <box> alarm boa ;

: register-alarm ( alarm -- )
    dup dup time>> alarms get-global heap-push*
    swap entry>> >box
    notify-alarm-thread ;

: alarm-expired? ( alarm now -- ? )
    [ time>> ] dip before=? ;

: reschedule-alarm ( alarm -- )
    dup [ swap interval>> time+ now max ] change-time register-alarm ;

: call-alarm ( alarm -- )
    [ entry>> box> drop ]
    [ quot>> "Alarm execution" spawn drop ]
    [ dup interval>> [ reschedule-alarm ] [ drop ] if ] tri ;

: (trigger-alarms) ( alarms now -- )
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
    now (trigger-alarms) ;

: next-alarm ( alarms -- timestamp/f )
    dup heap-empty?
    [ drop f ] [ heap-peek drop time>> ] if ;

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

[ init-alarms ] "alarms" add-init-hook

PRIVATE>

: add-alarm ( quot time frequency -- alarm )
    <alarm> [ register-alarm ] keep ;

: later ( quot duration -- alarm )
    hence f add-alarm ;

: every ( quot duration -- alarm )
    [ hence ] keep add-alarm ;

: cancel-alarm ( alarm -- )
    entry>> [ alarms get-global heap-delete ] if-box? ;
