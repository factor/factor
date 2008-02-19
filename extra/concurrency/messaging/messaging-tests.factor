! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel threads vectors arrays sequences
namespaces tools.test continuations dlists strings math words
match quotations concurrency.messaging ;
IN: temporary

[ ] [ mailbox mailbox-data dlist-delete-all ] unit-test

[ V{ 1 2 3 } ] [
    0 <vector>
    <mailbox>
    [ mailbox-get swap push ] in-thread
    [ mailbox-get swap push ] in-thread
    [ mailbox-get swap push ] in-thread
    1 over mailbox-put
    2 over mailbox-put
    3 swap mailbox-put
] unit-test

[ V{ 1 2 3 } ] [
    0 <vector>
    <mailbox>
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    1 over mailbox-put
    2 over mailbox-put
    3 swap mailbox-put
] unit-test

[ V{ 1 "junk" 3 "junk2" } [ 456 ] ] [
    0 <vector>
    <mailbox>
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ integer? ] swap mailbox-get? swap push ] in-thread
    [ [ string? ] swap mailbox-get? swap push ] in-thread
    [ [ string? ] swap mailbox-get? swap push ] in-thread
    1 over mailbox-put
    "junk" over mailbox-put
    [ 456 ] over mailbox-put
    3 over mailbox-put
    "junk2" over mailbox-put
    mailbox-get
] unit-test


[ "received" ] [ 
    [
        receive "received" swap reply-synchronous
    ] "Synchronous test" spawn
    "sent" swap send-synchronous
] unit-test

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
] [ linked-error "crash" = ] must-fail-with

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
    [ 0 [ counter ] [ ] [ ] while ] "Counter" spawn "counter" set
    { increment 10 } "counter" get send
    { decrement 15 } "counter" get send
    [ value , self , ] { } make "counter" get send
    receive
    exit "counter" get send
] unit-test