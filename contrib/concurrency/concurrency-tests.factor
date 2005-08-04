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
       sequences lists namespaces test errors ;

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

[ "test" ] [
  [ self get ] "test" with-process
] unit-test


[ "received" ] [ 
  [
    [ 
      [ message? [ [ drop ] [ "received" ] send-reply ] ]
    ]  recv
  ] spawn
  "sent" swap send-message
] unit-test

[ "pong" "shutdown" ] [
  pong-server "ping" over send-message
  swap "shutdown" swap send-message
] unit-test

[ "shutdown" 20 6 ] [
  rpc-server
  [ "add" 1 2 3 ] over send-message >r
  [ "product" 4 5 ] over send-message >r
  [ "shutdown" ] swap send-message 
  r> r>
] unit-test

[ "pong" "gnop" "pong" "gnop" ] [
  old-server "ping" over send-message >r
  new-server "ping" over send-message >r
  "ping" pick send-message >r
  "clone" over send-message <update> pick send
  "ping" pick send-message >r 
  3drop 
  r> r> r> r>
] unit-test 
  
[ f ] [
  [
    [
      "crash" throw
    ] spawn drop
  ] 
  [
  ] catch
] unit-test 
  
[ "crash" ] [
  [
    [
      "crash" throw
    ] spawn-link drop
    receive
  ] 
  [
  ] catch
] unit-test 
  
[ 55 ] [ [ 10 fib ] future ?future ] unit-test
[ 5 ] [ [ 5 fib ] lazy ?lazy ] unit-test
