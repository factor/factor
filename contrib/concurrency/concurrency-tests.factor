! Copyright (C) 2005 Chris Double. All Rights Reserved.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
IN: concurrency
USING: kernel concurrency concurrency-examples threads vectors 
       sequences lists namespaces test errors dlists strings 
       math words ;

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

[ { 1 2 3 } ] [
  0 <vector>
  make-mailbox
  2dup [ mailbox-get swap push ] cons cons in-thread
  2dup [ mailbox-get swap push ] cons cons in-thread
  2dup [ mailbox-get swap push ] cons cons in-thread
  1 over mailbox-put
  2 over mailbox-put
  3 swap mailbox-put
] unit-test

[ { 1 2 3 } ] [
  0 <vector>
  make-mailbox
  2dup [ [ integer? ] swap mailbox-get? swap push ] cons cons in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] cons cons in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] cons cons in-thread
  1 over mailbox-put
  2 over mailbox-put
  3 swap mailbox-put
] unit-test

[ { 1 "junk" 3 "junk2" } [ 456 ] ] [
  0 <vector>
  make-mailbox
  2dup [ [ integer? ] swap mailbox-get? swap push ] cons cons in-thread
  2dup [ [ integer? ] swap mailbox-get? swap push ] cons cons in-thread
  2dup [ [ string? ] swap mailbox-get? swap push ] cons cons in-thread
  2dup [ [ string? ] swap mailbox-get? swap push ] cons cons in-thread
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
    ] ifte
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
  << rpc-command f "product" [ 4 5 6 ] >> over send-synchronous >r
  << rpc-command f "add" [ 10 20 30  ] >> over send-synchronous >r
  << rpc-command f "shutdown" [      ] >> swap send-synchronous 
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

[ { 50 50 50 } ] [
  0 <vector>
  <promise>
  2dup [ ?promise swap push ] cons cons spawn drop
  2dup [ ?promise swap push ] cons cons spawn drop
  2dup [ ?promise swap push ] cons cons spawn drop
  50 swap fulfill
] unit-test  
