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
USING: concurrency kernel io lists threads math sequences namespaces unparser prettyprint errors ;

: (logger) ( mailbox -- )
  #! Using the given mailbox, start a thread which
  #! logs messages put into the box.
  dup mailbox-get print (logger) ;

: logger ( -- mailbox )
  #! Start a logging thread, which will log messages to the
  #! console that are put in the returned mailbox.
  make-mailbox dup [ (logger) ] cons in-thread ;

: pong-server ( -- server )
  #! A server that responds to a 'ping' message
  #! by sending  a 'pong' message to the caller.
  [
    [ 
      [ message?  [ [ "ping" = ] [ drop "pong" ] send-reply ] ]
      [ message?  [ [ "shutdown" = ] [ drop "shutdown" ] send-reply ] ] 
      [ message?  [ message-data "shutdown" = [ exit-server ] when ] ]
    ] recv 
  ] spawn-server ;

: rpc-server ( -- server )
  #! Process RPC requests where the message data
  #! is a list. The first item of the list is the function
  #! to execute. The remainder of the list are the arguments
  #! to that function.
  [
    [ 
      [ message? [ [ car "add"      = ] [ cdr 0 [ + ] reduce ] send-reply ] ]
      [ message? [ [ car "product"  = ] [ cdr 1 [ * ] reduce ] send-reply ] ]
      [ message? [ [ car "shutdown" = ] [ drop "shutdown" ] send-reply ] ] 
      [ message? [ message-data car "shutdown" = [ exit-server ] when ] ]
    ] recv 
  ] spawn-server ;

: original ( -- server )
  #! A server that responds to a clone request. This will 
  #! send back to the caller a continuation that when called 
  #! will effectively be a clone of the original server.
  [
    "original waiting for message: " write self get process-pid print
    [ 
      [ message? [ [ "clone" = ] [ drop server-cc ] maybe-send-reply ] ]
      [ message? [ [ "shutdown" = ] [ drop "shutdown" ] send-reply ] ] 
      [ message? [ message-data "shutdown" = [ exit-server ] when ] ]
    ] recv 
  ] spawn-server ;

: do-clone ( process -- )
  #! Given a server that responder to the 'clone' message, request
  #! a clone and execute it.
  [ "clone" swap send-message call-server-cc ] cons spawn ;

TUPLE: update k ;

: old-server ( -- server )
  [
    "old-server waiting for message: " write self get process-pid print
    [ 
      [ message? [ [ "clone" = ] [ drop server-cc ] maybe-send-reply ] ]
      [ message? [ [ "ping"  = ] [ drop "gnop" ] send-reply ] ]
      [ update?  [ update-k call-server-cc ] ]    
    ] recv 
  ] spawn-server ;

: new-server ( -- server )
  [
    "new-server waiting for message: " write self get process-pid unparse print
    [ 
      [ message? [ [ "clone" = ] [ drop server-cc ] maybe-send-reply ] ]
      [ message? [ [ "ping"  = ] [ drop "pong" ] send-reply ] ]
      [ update?  [ update-k call-server-cc ] ]    
    ] recv 
  ] spawn-server ;


: test-server-replacement ( -- )
  old-server 
  "Old Server is: " write dup process-pid print
  "Old Server result from ping is: " write "ping" over send-message .
  new-server
  "New Server is: " write dup process-pid print
  "New Server result from ping is: " write "ping" over send-message .
  "Old Server result from ping is: " write "ping" pick send-message . 
  "Sending code update to old server..." print
  "clone" over send-message <update> pick send
  "Old Server is: " write dup process-pid print
  "Old Server result from ping is: " write "ping" pick send-message . 
  2drop ;

! ***********************************
! Ignore code below...for testing
! ***********************************
: start-pong-server ( -- )
  [
    [
      [ message? [ [ "crash" = ] [ drop 1 0 /  ] send-reply ] ]
      [ message? [ [ "ping" =  ] [ drop "pong" ] send-reply ] ]
    ] recv  
  ] forever ;

: fragile-server ( -- server)
  [ start-pong-server ] spawn ;

SYMBOL: worker

: robust-server ( -- server )
  [
    [
      [
        [ start-pong-server ] spawn-link worker set
        [    
          receive dup message? [ 
            worker get !
          ] [
            drop
          ] ifte
        ] forever
      ]
      [
        [ 
          "Worker crashed, restarting: " write print           
        ] when*
      ]
      catch
    ] forever
  ] spawn ;

SYMBOL: set-next

: ring-process ( next -- server )
  #! A process that can receive a single message, 
  #! an integer number. That number is decremented then
  #! sent to the 'next' process. If the number is 0 it is
  #! relayed to the next process and this process exits.
  [
    [
      quit-cc set
      [        
        receive dup process? [
          "Setting next for " write self get process-pid print
          nip 
        ] [   
          dup 0 = [ ( next 0 -- )
            "0 received for " write self get process-pid print
            swap [ send ] when* 
            quit-cc get call
          ] [
            dup unparse write " received for " write self get process-pid print
            1 - over [ send ] when*
          ] ifte 
        ] ifte
      ] forever
    ] callcc0
    "Exiting process " write self get process-pid print
  ] cons spawn ;

: create-ring ( n -- process )
  #! Create a ring of n processes, returning one
  f ring-process dup rot 1 -
  [
    ring-process
  ] times over send ;

: fib ( n -- )
  yield
  dup 2 < [
    
  ] [
    dup 1 - >r 2 - fib r> fib + 
  ] ifte ;

TUPLE: fib-message number ;

: fib-server ( -- server )
  [
    "fib-server waiting for message: " write self get process-pid unparse print
    [ 
      [ message? [ [ fib-message? ] [ fib-message-number fib ] send-reply ] ]
    ] recv 
  ] spawn-server ;

: t1 
  f ring-process dup ring-process over send ;

: abcd 
  [
    "here" print
    receive 
    "there" print
    drop quit-cc call
  ] spawn-server ;

: pong-server1 ( -- process)
  [
    receive uncons "ping" = [
      "pong" swap send
    ] [
      "Pong server shutdown commenced" swap send
      exit-server
    ] ifte
  ] spawn-server ;

: pong-server2 ( -- process)
  [
    receive  
    dup [ "ping" =     ] [ drop "pong" ] send-reply
    dup [ "shutdown" = ] [ drop "Pong server shutdown commenced" ] send-reply
    message-data "shutdown" = [ exit-server ] when
  ] spawn-server ;