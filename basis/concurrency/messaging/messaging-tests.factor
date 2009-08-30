! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads vectors arrays sequences namespaces make
tools.test continuations deques strings math words match
quotations concurrency.messaging concurrency.mailboxes
concurrency.count-downs concurrency.conditions accessors calendar ;
IN: concurrency.messaging.tests

[ ] [ my-mailbox data>> clear-deque ] unit-test

[ "received" ] [ 
    [
        receive "received" swap reply-synchronous
    ] "Synchronous test" spawn
    "sent" swap send-synchronous
] unit-test

[ "received" ] [ 
    [
        receive "received" swap reply-synchronous
    ] "Synchronous test" spawn
    [ 100 milliseconds "sent" ] dip send-synchronous-timeout
] unit-test

[ [ 100 milliseconds sleep
    receive "received" swap reply-synchronous ] "Synchronous test" spawn
  [ 50 milliseconds "sent" ] dip send-synchronous-timeout
] [ wait-timeout? ] must-fail-with


[ 1 3 2 ] [
    1 self send
    2 self send
    3 self send
    receive
    [ 2 mod 0 = not ] receive-if
    receive
] unit-test

[
    [
        "crash" throw
    ] "Linked test" spawn-linked drop
    receive
] [ error>> "crash" = ] must-fail-with

MATCH-VARS: ?from ?to ?value ;
SYMBOL: increment
SYMBOL: decrement
SYMBOL: value
SYMBOL: exit

: counter ( value -- value ? )
    receive {
        { { increment ?value } [ ?value + t ] }
        { { decrement ?value } [ ?value - t ] }
        { { value ?from }      [ dup ?from send t ] }
        { exit                 [ f ] }
    } match-cond ;

[ -5 ] [
    [ 0 [ counter ] loop ] "Counter" spawn "counter" set
    { increment 10 } "counter" get send
    { decrement 15 } "counter" get send
    [ value , self , ] { } make "counter" get send
    receive
    exit "counter" get send
] unit-test

! Not yet

! 1 <count-down> "c" set

! [
!     "c" get count-down
!     receive drop
! ] "Bad synchronous send" spawn "t" set

! [ 3 "t" get send-synchronous ] must-fail
