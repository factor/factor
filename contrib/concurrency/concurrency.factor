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
! Concurrency library for Factor based on Erlang/Termite style
! concurrency.
USING: kernel lists generic threads io namespaces errors words 
       math sequences hashtables unparser strings vectors ;
IN: concurrency

#! Debug
USE:  prettyprint

TUPLE: mailbox threads data ;

: make-mailbox ( -- mailbox )
  #! A mailbox is an object that can be used for safe thread
  #! communication. Items can be put in the mailbox and retrieved in a
  #! FIFO order. If the mailbox is empty when a get operation is 
  #! performed then the thread will block until another thread places 
  #! something in the mailbox. If multiple threads are waiting on the 
  #! same mailbox, only one of the waiting threads will be unblocked 
  #! to process the get operation.
  0 <vector> <queue> <mailbox> ;

: mailbox-empty? ( mailbox -- bool )
  #! Return true if the mailbox is empty
  mailbox-data queue-empty? ;

: mailbox-put ( obj mailbox -- )
  #! Put the object into the mailbox. If the mailbox 
  #! is empty and a thread has a blocking get on it
  #! then that thread is resumed. If more than one thread
  #! is waiting, then only one of those threads will be
  #! resumed.
  dup  mailbox-empty? -rot
  swap over mailbox-data enque over set-mailbox-data swap [
    dup mailbox-threads 0 <vector> rot set-mailbox-threads [
      [ schedule-thread ] each yield
    ] when*
  ] when ;

: (mailbox-block-if-empty) ( mailbox -- obj )  
  #! Block the thread if the mailbox is empty
  dup mailbox-empty? [
    [
      swap mailbox-threads push stop      
    ] callcc0 
    (mailbox-block-if-empty)
  ] when ;
  
: mailbox-get ( mailbox -- obj )
  #! Get the first item put into the mailbox. If it is
  #! empty the thread blocks until an item is put into it.
  #! The thread then resumes, leaving the item on the stack.
  (mailbox-block-if-empty)
  dup mailbox-data deque rot set-mailbox-data ;
 

#! Processes run on nodes identified by a hostname and port.
TUPLE: node hostname port ;
 
: localnode ( -- node )
  #! Return the default node on the localhost
  "localhost" 9000 <node> ;

#! Processes run in nodes. Each process has a mailbox that is
#! used for receiving messages sent to that process.
TUPLE: process node links pid mailbox ;

: make-process ( -- process )
  #! Return a process set to run on the local node. A process is 
  #! similar to a thread but can send and receive messages to and
  #! from other processes. It may also be linked to other processes so
  #! that it receives a message if that process terminates.
  localnode [ ] gensym unparse make-mailbox <process> ;

: make-linked-process ( process -- process )
  #! Return a process set to run on the local node. That process is
  #! linked to the process on the stack. It will receive a message if
  #! that process terminates.
  localnode swap unit gensym unparse make-mailbox <process> ;

#! The 'self' variable returns the currently executing process.
SYMBOL: self

: init-main-process ( -- )
  #! Setup the main process.
  make-process self set ;

init-main-process

: with-process ( quot process -- )
  #! Calls the quotation with 'self' set
  #! to the given process.
  <namespace> [
    self set
  ] extend
  swap bind ;

: spawn ( quot -- process )
  #! Start a process which runs the given quotation.
  [ [ drop ] catch ] cons
  [ in-thread ] make-process [ with-process ] over slip ;

TUPLE: linked-exception error ;

: send ( message process -- )
  #! Send the message to the process by placing it in the
  #! processes mailbox. 
  process-mailbox mailbox-put ;

: receive ( -- message )
  #! Return a message from the current processes mailbox.
  #! If the box is empty, suspend the process until something
  #! is placed in the box.
  self get process-mailbox mailbox-get dup linked-exception? [
    linked-exception-error throw
  ] when ;

: rethrow-linked ( error -- )
  #! Rethrow the error to the linked process
  self get process-links [ over <linked-exception> swap send ] each drop ;

: spawn-link ( quot -- process )
  #! Same as spawn but if the quotation throws an error that
  #! is uncaught, that error gets propogated to the process
  #! performing the spawn-link.
  [ [ [ rethrow-linked ] when* ] catch ] cons
  [ in-thread ] self get make-linked-process [ with-process ] over slip ;

#! A common operation is to send a message to a process containing
#! the sending process so the receiver can send a reply back. A 'tag'
#! is also sent so that the sender can match the reply with the
#! original request. The 'message' tuple ecapsulates this.
TUPLE: message data from tag ;

: >message< ( message -- data from tag )
  #! Explode a message tuple.
  dup message-data swap
  dup message-from swap
  message-tag ;

: (recv) ( msg form -- )
  #! Process a form with the following format:
  #!   [ pred match-quot ] 
  #! 'pred' is a word that has stack effect ( msg -- bool ). It is 
  #! executed with the message on the stack. It should return a 
  #! boolean if it is a message this form should process.
  #! 'match-quot' is a quotation with stack effect ( msg -- ). It
  #! will be called with the message on the top of the stack if
  #! the 'pred' word returned true.
  uncons >r dupd execute [
    r> car call
  ] [
    r> 2drop
  ] ifte ;

: recv ( forms -- ) 
  #! Get a message from the processes mailbox. Compare it against the
  #! forms to run a quotation if it matches the given message. 'forms'
  #! is a list of quotations in the following format:
  #!   [ pred match-quot ] 
  #! 'pred' is a word that has stack effect ( msg -- bool ). It is 
  #! executed with the message on the stack. It should return a 
  #! boolean if it is a message this form should process.
  #! 'match-quot' is a quotation with stack effect ( msg -- ). It
  #! will be called with the message on the top of the stack if
  #! the 'pred' word returned true.
  #! Each form in the list will be matched against the message, 
  #! even if a prior match succeeded. This means multiple quotations
  #! may be run against the message.
  receive swap [ dupd (recv) ] each drop ;

: send-message ( data process -- reply )
  #! Sends a message to the process using the 'message' 
  #! protocol and waits for a reply to that message. The reply
  #! is matched up with the request by generating a message tag
  #! which should be sent back with the reply.
  swap self get gensym dup >r <message> 
  swap send 
  r> receive 
  dup message? [
    dup message-tag rot = [
      message-data
    ] [
      2drop f
    ] ifte
  ] [
    2drop f
  ] ifte ;

: forever ( quot -- )
  #! Loops forever executing the quotation.
  dup >r call r> forever ; 

SYMBOL: quit-cc

: spawn-server ( quot -- process )
  #! Spawn a server that runs the quotation in
  #! a loop. A continuation in the variable 'quit-cc' is available
  #! that when called will exit the loop.
  [  
    [
      quit-cc set      
      forever 
    ] callcc0
    "Exiting process: " write self get process-pid print
  ] cons spawn ;

: spawn-linked-server ( quot -- process )
  #! Spawn a linked server that runs forever.
  [  
    [
      quit-cc set      
      forever 
    ] callcc0
    "Exiting process: " write self get process-pid print
  ] cons spawn-link ;

: exit-server ( -- )
  #! Calls the quit continuation to exit a server.
  quit-cc get call ;

: send-reply ( message pred quot -- )
  #! The intent of this word is to provde an easy way to
  #! check the data contained in a message, process it, and
  #! return a result to the original sender.
  #! Given a message tuple, call 'pred' given the
  #! message data from that tuple on the top of the stack. 
  #! 'pred' should have stack effect ( data -- boolean ).
  #! If 'pred' returns true, call 'quot' with the message 
  #! data from the message tuple on the stack. 'quot' has
  #! stack effect ( data -- result ).
  #! The result of that call will be sent back to the 
  #! messages original caller with the same tag as the 
  #! original message.
  >r >r >message< rot ( from tag data r: quot pred )
  dup r> call [   ( from tag data r: quot )
    r> call       ( from tag result )
    self get      ( from tag result self )
    rot           ( from self tag result )
    <message> swap send
  ] [
    r> drop 3drop
  ] ifte ;

SYMBOL: exit

: maybe-send-reply ( message pred quot -- )
  #! Same as !result but if false is returned from
  #! quot then nothing is sent back to the caller.
  >r >r >message< rot ( from tag data r: quot pred )
  dup r> call [   ( from tag data r: quot )
    r> call       ( from tag result )
    [
      self get      ( from tag result self )
      rot           ( from self tag result )
      <message> swap send
    ] [
      2drop
    ] ifte*
  ] [
    r> drop 3drop
  ] ifte ;

: server-cc ( -- cc | process)
  #! Captures the current continuation and returns the value.
  #! If that CC is called with a process on the stack it will
  #! set 'self' for the current process to it. Otherwise it will
  #! return the value. This allows capturing a continuation in a server,
  #! and jumping back into it from a spawn and keeping the 'self'
  #! variable correct. It's a workaround until I can find out how to
  #! stop 'self' from being clobbered back to its old value.
  [ ] callcc1 dup process? [ self set f ] when ;
  
: call-server-cc ( server-cc -- )
  #! Calls the server continuation passing the current 'self'
  #! so the server continuation gets its new self updated.
  self get swap call ;

: future ( quot -- future )
  #! Spawn a process to call the quotation and immediately return
  #! a 'future' on the stack. The future can later be queried with
  #! ?future. If the quotation has completed the result will be returned.
  #! If not, the process will block until the quotation completes.
  #! 'quot' must have stack effect ( -- X ).
  [ call self get send ] cons spawn ;

: ?future ( future -- result )
  #! Block the process until the future has completed and then place the
  #! result on the stack. Return the result immediately if the future has completed.
  process-mailbox mailbox-get ;
  
SYMBOL: lazy-quot

: lazy ( quot -- lazy )
  #! Spawn a process that immediately blocks and return it. 
  #! When '?lazy' is called on the returned process, call the quotation
  #! and return the result. The quotation must have stack effect ( -- X ).
  [
    [
      lazy-quot set      
      [
        [ message? [ [ drop t ] [ get call ] send-reply ] ]
      ] recv
    ] with-scope
  ] cons spawn ;

: ?lazy ( lazy -- result )
  #! Given a process spawned using 'lazy', evaluate it and return the result.
  lazy-quot swap send-message ;

