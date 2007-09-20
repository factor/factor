! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: arrays calendar concurrency generic kernel math
namespaces sequences threads ;
IN: alarms-internals

! for now a V{ }, eventually a min-heap to store alarms
SYMBOL: alarms
SYMBOL: alarm-receiver
SYMBOL: alarm-looper

TUPLE: alarm time quot ;

: add-alarm ( alarm -- )
    alarms get-global push ;

: remove-alarm ( alarm -- )
    alarms get-global remove alarms set-global ;

: handle-alarm ( alarm -- )
    dup delegate {
        { "register" [ add-alarm ] }
        { "unregister" [ remove-alarm  ] }
    } case ;
    
: expired-alarms ( -- seq )
    now alarms get-global
    [ alarm-time compare-timestamps 0 > ] subset-with ;

: unexpired-alarms ( -- seq )
    now alarms get-global
    [ alarm-time compare-timestamps 0 <= ] subset-with ;

: call-alarm ( alarm -- )
    alarm-quot spawn drop ;
    
: do-alarms ( -- )
    alarms get-global expired-alarms
    [ call-alarm ] each
    unexpired-alarms alarms set-global ;

: alarm-receive-loop ( -- )
    receive dup alarm? [ handle-alarm ] [ drop ] if
    alarm-receive-loop ;

: start-alarm-receiver ( -- )
    [
        alarm-receive-loop
    ] spawn alarm-receiver set-global ;

: alarm-loop ( -- )
    alarms get-global empty? [
        do-alarms
    ] unless 100 sleep alarm-loop ;
    
: start-alarm-looper ( -- )
    [
        alarm-loop
    ] spawn alarm-looper set-global ;

: send-alarm ( alarm -- )
    over set-delegate
    alarm-receiver get-global send ;

: start-alarm-daemon ( -- process )
    alarms get-global [
        V{ } clone alarms set-global
        start-alarm-looper
        start-alarm-receiver
    ] unless ;

start-alarm-daemon

IN: alarms

: register-alarm ( alarm -- )
    "register" send-alarm ;

: unregister-alarm ( alarm -- )
    "unregister" send-alarm ;

: change-alarm ( alarm-old alarm-new -- )
    "register" send-alarm
    "unregister" send-alarm ;
 

! Example:
! now 5 seconds +dt [ "hi" print flush ] <alarm> register-alarm
