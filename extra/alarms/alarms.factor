! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays calendar combinators generic init kernel math
namespaces sequences heaps boxes threads debugger quotations
assocs ;
IN: alarms

TUPLE: alarm quot time interval entry ;

<PRIVATE

SYMBOL: alarms
SYMBOL: alarm-thread

: notify-alarm-thread ( -- )
    alarm-thread get-global interrupt ;

: check-alarm
    dup dt? over not or [ "Not a dt" throw ] unless
    over timestamp? [ "Not a timestamp" throw ] unless
    pick callable? [ "Not a quotation" throw ] unless ; inline

: <alarm> ( quot time frequency -- alarm )
    check-alarm <box> alarm construct-boa ;

: register-alarm ( alarm -- )
    dup dup alarm-time alarms get-global heap-push*
    swap alarm-entry >box
    notify-alarm-thread ;

: alarm-expired? ( alarm now -- ? )
    >r alarm-time r> <=> 0 <= ;

: reschedule-alarm ( alarm -- )
    dup alarm-time over alarm-interval +dt
    over set-alarm-time
    register-alarm ;

: call-alarm ( alarm -- )
    dup alarm-quot try
    dup alarm-entry box> drop
    dup alarm-interval [ reschedule-alarm ] [ drop ] if ;

: (trigger-alarms) ( alarms now -- )
    over heap-empty? [
        2drop
    ] [
        over heap-peek drop over alarm-expired? [
            over heap-pop drop call-alarm
            (trigger-alarms)
        ] [
            2drop
        ] if
    ] if ;

: trigger-alarms ( alarms -- )
    now (trigger-alarms) ;

: next-alarm ( alarms -- ms )
    dup heap-empty?
    [ drop f ]
    [ heap-peek drop alarm-time now timestamp- 1000 * 0 max ]
    if ;

: alarm-thread-loop ( -- )
    alarms get-global
    dup next-alarm nap drop
    dup trigger-alarms
    alarm-thread-loop ;

: cancel-alarms ( alarms -- )
    [
        heap-pop-all [ nip alarm-entry box> drop ] assoc-each
    ] when* ;

: init-alarms ( -- )
    alarms global [ cancel-alarms <min-heap> ] change-at
    [ alarm-thread-loop ] "Alarms" spawn
    alarm-thread set-global ;

[ init-alarms ] "alarms" add-init-hook

PRIVATE>

: add-alarm ( quot time frequency -- alarm )
    <alarm> [ register-alarm ] keep ;

: later ( quot dt -- alarm )
    from-now f add-alarm ;

: cancel-alarm ( alarm -- )
    alarm-entry ?box
    [ alarms get-global heap-delete ] [ drop ] if ;
