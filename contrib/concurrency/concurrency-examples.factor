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
! Examples of using the concurrency library.
IN: concurrency-examples
USING: concurrency dlists errors gadgets-theme gadgets-panes io kernel lists
math math-contrib namespaces opengl prettyprint sequences threads ;

: (logger) ( mailbox -- )
  #! Using the given mailbox, start a thread which
  #! logs messages put into the box.
  dup mailbox-get print (logger) ;

: logger ( -- mailbox )
  #! Start a logging thread, which will log messages to the
  #! console that are put in the returned mailbox.
  make-mailbox dup [ (logger) ] cons in-thread ;

: (pong-server0) ( -- )
  receive uncons "ping" = [
    "pong" swap send (pong-server0)
  ] [
    "Pong server shutting down" swap send
  ] if ;
  
: pong-server0 ( -- process )
  [ (pong-server0) ] spawn ;

TUPLE: ping-message from ;
TUPLE: shutdown-message from ;

GENERIC: handle-message

M: ping-message handle-message ( message -- bool )
  ping-message-from "pong" swap send t ;

M: shutdown-message handle-message ( message -- bool )
  shutdown-message-from "Pong server shutdown commenced" swap send f ;

: (pong-server1) ( -- )
  "pong-server1 waiting for message..." print
  receive handle-message [ (pong-server1) ] when ;

: pong-server1 ( -- process )
  [ 
    (pong-server1) 
    "pong-server1 exiting..." print
  ] spawn ;

TUPLE: echo-message from text ;

M: echo-message handle-message ( message -- bool )
  dup echo-message-text swap echo-message-from send  t ;

GENERIC: handle-message2
PREDICATE: tagged-message ping-message2 ( obj -- ? ) tagged-message-data "ping" = ;
PREDICATE: tagged-message shutdown-message2 ( obj -- ? ) tagged-message-data "shutdown" = ;

M: ping-message2 handle-message2 ( message -- bool ) 
  "pong" reply t ;

M: shutdown-message2 handle-message2 ( message -- bool )  
  "Pong server shutdown commenced" reply f ;

: (pong-server2) ( -- )
  "pong-server2 waiting for message..." print
  receive handle-message2 [ (pong-server2) ] when ;

: pong-server2 ( -- process )
  [ 
    (pong-server2) 
    "pong-server2 exiting..." print
  ] spawn ;

: pong-server3 ( -- process )
  [ handle-message2 ] spawn-server ;

GENERIC: handle-rpc-message
GENERIC: run-rpc-command 

TUPLE: rpc-command op args ;
PREDICATE: rpc-command add-command ( msg -- bool )
  rpc-command-op "add" = ;
PREDICATE: rpc-command product-command ( msg -- bool )
  rpc-command-op "product" = ;
PREDICATE: rpc-command shutdown-command ( msg -- bool )
  rpc-command-op "shutdown" = ;
PREDICATE: rpc-command crash-command ( msg -- bool )
  rpc-command-op "crash" = ;

M: tagged-message handle-rpc-message ( message -- bool )
  dup tagged-message-data run-rpc-command -rot reply not ;

M: add-command run-rpc-command ( command -- shutdown? result )
  rpc-command-args sum f ;

M: product-command run-rpc-command ( command -- shutdown? result )
  rpc-command-args product f ;

M: shutdown-command run-rpc-command ( command -- shutdown? result )
  drop t t ;

M: crash-command run-rpc-command ( command -- shutdown? result )
  drop 1 0 / f ;

: fragile-rpc-server ( -- process )
  [ handle-rpc-message ] spawn-server ;

: (robust-rpc-server) ( worker -- )
  [
    receive over send
  ] 
  catch 
  [  
    "Worker died, Starting a new worker" print
    drop [ handle-rpc-message ] spawn-linked-server
  ] when
  (robust-rpc-server) ;
  
: robust-rpc-server ( -- process )
  [
    [ handle-rpc-message ] spawn-linked-server
    (robust-rpc-server)
  ] spawn ;

: test-add ( process -- )
  [ 
    "add" [ 1 2 3 ] <rpc-command> swap send-synchronous .
  ] cons spawn drop ;

: test-crash ( process -- )
  [ 
    "crash" f <rpc-command> swap send-synchronous .
  ] cons spawn drop ;
  
! ******************************
! Experimental code below
! ******************************
USE: gadgets
USE: gadgets-labels
USE: gadgets-presentations
USE: gadgets-layouts
USE: generic

TUPLE: promised-label promise font color ;

C: promised-label ( promise -- promised-label )
  dup delegate>gadget dup label-theme
  [ set-promised-label-promise ] keep 
  [ [ dup promised-label-promise ?promise drop relayout ] cons spawn drop ] keep ;

: promised-label-text ( promised-label -- text )
  promised-label-promise dup promise-fulfilled? [
    ?promise
  ] [
    drop "Unfulfilled Promise" 
  ] if ;

M: promised-label pref-dim* ( promised-label - dim )
  label-size ;

M: promised-label draw-gadget* ( promised-label -- )
    draw-label ;

M: promised-label label-text promised-label-text ;

M: promised-label label-color promised-label-color ;

M: promised-label label-font promised-label-font ;

M: promised-label set-label-color set-promised-label-color ;

M: promised-label set-label-font set-promised-label-font ;

: fib ( n -- n )
  yield dup 2 < [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ;
  
: test-promise-ui ( -- )
  <promise> dup <promised-label> gadget. [ 30 fib unparse swap fulfill ] cons spawn drop ;
