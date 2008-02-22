! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays calendar combinators generic init kernel math
namespaces sequences heaps boxes threads debugger quotations ;
IN: alarms

TUPLE: alarm time interval quot entry ;

: check-alarm
    pick timestamp? [ "Not a timestamp" throw ] unless
    over dup dt? swap not or [ "Not a dt" throw ] unless
    dup callable? [ "Not a quotation" throw ] unless ; inline

: <alarm> ( time delay quot -- alarm )
    check-alarm <box> alarm construct-boa ;

! Global min-heap
SYMBOL: alarms
SYMBOL: alarm-thread

: notify-alarm-thread ( -- )
    alarm-thread get-global interrupt ;

: add-alarm ( time delay quot -- alarm )
    <alarm> [
        dup dup alarm-time alarms get-global heap-push*
        swap alarm-entry >box
        notify-alarm-thread
    ] keep ;

: cancel-alarm ( alarm -- )
    alarm-entry box> alarms get-global heap-delete ;

: alarm-expired? ( alarm now -- ? )
    >r alarm-time r> <=> 0 <= ;

: reschedule-alarm ( alarm -- )
    dup alarm-time over alarm-interval +dt
    over set-alarm-time
    add-alarm drop ;

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
    [ drop f ] [
        heap-peek drop alarm-time now
        [ timestamp>unix-time ] 2apply [-] 1000 *
    ] if ;

: alarm-thread-loop ( -- )
    alarms get-global
    dup next-alarm nap drop
    dup trigger-alarms
    alarm-thread-loop ;

: init-alarms ( -- )
    <min-heap> alarms set-global
    [ alarm-thread-loop ] "Alarms" spawn
    alarm-thread set-global ;

[ init-alarms ] "alarms" add-init-hook
