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
    dup duration? over not or [ "Not a duration" throw ] unless
    over timestamp? [ "Not a timestamp" throw ] unless
    pick callable? [ "Not a quotation" throw ] unless ; inline

: <alarm> ( quot time frequency -- alarm )
    check-alarm <box> alarm boa ;

: register-alarm ( alarm -- )
    dup dup alarm-time alarms get-global heap-push*
    swap alarm-entry >box
    notify-alarm-thread ;

: alarm-expired? ( alarm now -- ? )
    >r alarm-time r> before=? ;

: reschedule-alarm ( alarm -- )
    dup alarm-time over alarm-interval time+
    over set-alarm-time
    register-alarm ;

: call-alarm ( alarm -- )
    dup alarm-entry box> drop
    dup alarm-quot "Alarm execution" spawn drop
    dup alarm-interval [ reschedule-alarm ] [ drop ] if ;

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
    [ drop f ] [ heap-peek drop alarm-time ] if ;

: alarm-thread-loop ( -- )
    alarms get-global
    dup next-alarm sleep-until
    trigger-alarms ;

: cancel-alarms ( alarms -- )
    [
        heap-pop-all [ nip alarm-entry box> drop ] assoc-each
    ] when* ;

: init-alarms ( -- )
    alarms global [ cancel-alarms <min-heap> ] change-at
    [ alarm-thread-loop t ] "Alarms" spawn-server
    alarm-thread set-global ;

[ init-alarms ] "alarms" add-init-hook

PRIVATE>

: add-alarm ( quot time frequency -- alarm )
    <alarm> [ register-alarm ] keep ;

: later ( quot dt -- alarm )
    from-now f add-alarm ;

: every ( quot dt -- alarm )
    [ from-now ] keep add-alarm ;

: cancel-alarm ( alarm -- )
    alarm-entry [ alarms get-global heap-delete ] if-box? ;
