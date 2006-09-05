! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel concurrency concurrency-examples threads vectors 
       sequences namespaces test errors dlists strings math words match ;
IN: temporary

[ "junk" ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] swap dlist-pop? 
] unit-test

[ 5 20 ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] over dlist-pop? drop
  [ ] dlist-each
] unit-test

[ "junk" ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ integer? ] over dlist-pop? drop
  [ integer? ] over dlist-pop? drop
  [ ] dlist-each
] unit-test

[ t ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] swap dlist-pred?
] unit-test

[ t ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ integer? ] swap dlist-pred?
] unit-test

[ f ] [ 
  <dlist> 
  5 over dlist-push-end 
  "junk" over dlist-push-end 
  20 over dlist-push-end 
  [ string? ] over dlist-pop? drop
  [ string? ] swap dlist-pred?
] unit-test

[ V{ 1 2 3 } ] [
  0 <vector>
  make-mailbox
  2dup [ mailbox-get swap push ] curry curry in-thread
  2dup [ mailbox-get swap push ] curry curry in-thread
  2dup [ mailbox-get swap push ] curry curry in-thread
  1 over mailbox-put
  2 over mailbox-put
  3 swap mailbox-put
] unit-test

[ V{ 1 2 3 } ] [
  0 <vector>
  make-mailbox
  2dup [ [ integer? ] swap mailbox-get? swap push ] curry curry in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] curry curry in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] curry curry in-thread
  1 over mailbox-put
  2 over mailbox-put
  3 swap mailbox-put
] unit-test

[ V{ 1 "junk" 3 "junk2" } [ 456 ] ] [
  0 <vector>
  make-mailbox
  2dup [ [ integer? ] swap mailbox-get? swap push ] curry curry in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] curry curry in-thread
  2dup [ [ string? ] swap mailbox-get? swap push ] curry curry in-thread
  2dup [ [ string? ] swap mailbox-get? swap push ] curry curry in-thread
  1 over mailbox-put
  "junk" over mailbox-put
  [ 456 ] over mailbox-put
  3 over mailbox-put
  "junk2" over mailbox-put
  mailbox-get
] unit-test

[ f ] [ 1 2 gensym <tagged-message> gensym tag-match? ] unit-test
[ f ] [ "junk" gensym tag-match? ] unit-test
[ t ] [ 1 2 gensym <tagged-message> dup tagged-message-tag tag-match? ] unit-test

[ "test" ] [
  [ self ] "test" with-process
] unit-test


[ "received" ] [ 
  [
    receive dup tagged-message? [
      "received" reply    
    ] [
      drop f
    ] if
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

[ "pong" "Pong server shutdown commenced" ] [
  pong-server3 "ping" over send-synchronous
  swap "shutdown" swap send-synchronous
] unit-test

[ t 60 120 ] [
  fragile-rpc-server
  T{ rpc-command f "product" [ 4 5 6 ] } over send-synchronous >r
  T{ rpc-command f "add" [ 10 20 30  ] } over send-synchronous >r
  T{ rpc-command f "shutdown" [      ] } swap send-synchronous 
  r> r>    
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
  2dup [ ?promise swap push ] curry curry spawn drop
  2dup [ ?promise swap push ] curry curry spawn drop
  2dup [ ?promise swap push ] curry curry spawn drop
  50 swap fulfill
] unit-test  

SYMBOL: ?value
SYMBOL: ?from
SYMBOL: ?tag
SYMBOL: increment
SYMBOL: decrement
SYMBOL: value

: counter ( value -- )
  receive {
    { { increment ?value } [ ?value get + counter ] }
    { { decrement ?value } [ ?value get - counter ] }
    { { value ?from }      [ dup ?from get send counter ] }
  } match-cond ;

[ -5 ] [
  [ 0 counter ] spawn
  { increment 10 } over send
  { decrement 15 } over send
  [ value , self , ] { } make swap send 
  receive
] unit-test