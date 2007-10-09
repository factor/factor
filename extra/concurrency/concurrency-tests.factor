! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel concurrency threads vectors arrays sequences
namespaces tools.test continuations dlists strings math words
match quotations concurrency.private ;
IN: temporary

[ V{ 1 2 3 } ] [
  0 <vector>
  make-mailbox
  2dup [ mailbox-get swap push ] 2curry in-thread
  2dup [ mailbox-get swap push ] 2curry in-thread
  2dup [ mailbox-get swap push ] 2curry in-thread
  1 over mailbox-put
  2 over mailbox-put
  3 swap mailbox-put
] unit-test

[ V{ 1 2 3 } ] [
  0 <vector>
  make-mailbox
  2dup [ [ integer? ] swap mailbox-get? swap push ] 2curry in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] 2curry in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] 2curry in-thread
  1 over mailbox-put
  2 over mailbox-put
  3 swap mailbox-put
] unit-test

[ V{ 1 "junk" 3 "junk2" } [ 456 ] ] [
  0 <vector>
  make-mailbox
  2dup [ [ integer? ] swap mailbox-get? swap push ] 2curry in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] 2curry in-thread
  2dup [ [ string? ] swap mailbox-get? swap push ] 2curry in-thread
  2dup [ [ string? ] swap mailbox-get? swap push ] 2curry in-thread
  1 over mailbox-put
  "junk" over mailbox-put
  [ 456 ] over mailbox-put
  3 over mailbox-put
  "junk2" over mailbox-put
  mailbox-get
] unit-test

[ "test" ] [
  [ self ] "test" with-process
] unit-test


[ "received" ] [ 
  [
    receive { 
      { { ?from ?tag _ } [ ?tag "received" 2array ?from send ] } 
    } match-cond
  ] spawn
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


[ "crash" ] [
  [
    [
      "crash" throw
    ] spawn-link drop
    receive
  ] 
  catch
] unit-test 

[ 50 ] [
  [ 50 ] future ?future
] unit-test

[ V{ 50 50 50 } ] [
  0 <vector>
  <promise>
  2dup [ ?promise swap push ] 2curry spawn drop
  2dup [ ?promise swap push ] 2curry spawn drop
  2dup [ ?promise swap push ] 2curry spawn drop
  50 swap fulfill
] unit-test  

MATCH-VARS: ?value ;
SYMBOL: increment
SYMBOL: decrement
SYMBOL: value

: counter ( value -- )
  receive {
    { { increment ?value } [ ?value + counter ] }
    { { decrement ?value } [ ?value - counter ] }
    { { value ?from }      [ dup ?from send counter ] }
  } match-cond ;

[ -5 ] [
  [ 0 counter ] spawn
  { increment 10 } over send
  { decrement 15 } over send
  [ value , self , ] { } make swap send 
  receive
] unit-test

! The following unit test blocks forever if the
! exception does not propogate. Uncomment when
! this is fixed (via a timeout).
! [
!  [ "this should propogate" throw ] future ?future 
! ] unit-test-fails

[ ] [
  [ "this should not propogate" throw ] future drop 
] unit-test

[ f ] [
  [ 1 drop ] spawn 100 sleep process-pid get-process
] unit-test

[ f ] [
  [ "testing unregistering on error" throw ] spawn 
  100 sleep process-pid get-process
] unit-test 