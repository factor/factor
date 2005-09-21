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
       math sequences hashtables unparser strings vectors dlists ;
IN: concurrency

#! Debug
USE:  prettyprint

: (dlist-pop?) ( dlist pred dnode -- obj | f )
  [
    [ dlist-node-data swap call ] 2keep rot [
      swapd [ (dlist-unlink) ] keep dlist-node-data nip
    ] [
      dlist-node-next (dlist-pop?)
    ] ifte
  ] [
    2drop f
  ] ifte* ;

: dlist-pop? ( pred dlist -- obj | f )
  #! Return first item in the dlist that when passed to the
  #! predicate quotation, true is left on the stack. The
  #! item is removed from the dlist. The 'pred' quotation
  #! must have stack effect ( obj -- bool ).
  #! TODO: needs a better name and should be moved to dlists.
  dup dlist-first swapd (dlist-pop?) ;  

: (dlist-pred?) ( pred dnode -- bool )
  [
    [ dlist-node-data swap call ] 2keep rot [
      2drop t
    ] [
      dlist-node-next (dlist-pred?)
    ] ifte
  ] [
    drop f
  ] ifte* ;

: dlist-pred? ( pred dlist -- obj | f )
  #! Return true if any item in the dlist that when passed to the
  #! predicate quotation, true is left on the stack. 
  #! The 'pred' quotation must have stack effect ( obj -- bool ).
  #! TODO: needs a better name and should be moved to dlists.
  dlist-first (dlist-pred?) ;  

TUPLE: mailbox threads data ;

: make-mailbox ( -- mailbox )
  #! A mailbox is an object that can be used for safe thread
  #! communication. Items can be put in the mailbox and retrieved in a
  #! FIFO order. If the mailbox is empty when a get operation is 
  #! performed then the thread will block until another thread places 
  #! something in the mailbox. If multiple threads are waiting on the 
  #! same mailbox, only one of the waiting threads will be unblocked 
  #! to process the get operation.
  0 <vector> <dlist> <mailbox> ;

: mailbox-empty? ( mailbox -- bool )
  #! Return true if the mailbox is empty
  mailbox-data dlist-empty? ;

: mailbox-put ( obj mailbox -- )
  #! Put the object into the mailbox. Any threads that have
  #! a blocking get on the mailbox are resumed.
  [ mailbox-data dlist-push-end ] keep 
  [ mailbox-threads ] keep 0 <vector> swap set-mailbox-threads
  [ schedule-thread ] each yield ;

: (mailbox-block-unless-pred) ( pred mailbox -- pred mailbox )  
  #! Block the thread if there are not items in the mailbox
  #! that return true when the predicate is called with the item
  #! on the stack. The predicate must have stack effect ( X -- bool ).
  dup mailbox-data pick swap dlist-pred? [
    [
      swap mailbox-threads push stop      
    ] callcc0 
    (mailbox-block-unless-pred)
  ] unless ;

: (mailbox-block-if-empty) ( mailbox -- mailbox )  
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
  mailbox-data dlist-pop-front ;
 
: mailbox-get? ( pred mailbox -- obj )
  #! Get the first item in the mailbox which satisfies the predicate.
  #! 'pred' will be called with each item on the stack. When pred returns
  #! true that item will be returned. If nothing in the mailbox 
  #! satisfies the predicate then the thread will block until something does.
  (mailbox-block-unless-pred)
  mailbox-data dlist-pop? ;

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

#! The 'self-process' variable holds the currently executing process.
SYMBOL: self-process

: self ( -- process )
  #! Returns the contents of the 'self-process' variables which
  #! is the process object for the current process.
  self-process get ;

: init-main-process ( -- )
  #! Setup the main process.
  make-process self-process set ;

init-main-process

: with-process ( quot process -- )
  #! Calls the quotation with 'self' set
  #! to the given process.
  [
    self-process set
  ] make-hash
  swap bind ;

: spawn ( quot -- process )
  #! Start a process which runs the given quotation.
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
  self process-mailbox mailbox-get dup linked-exception? [
    linked-exception-error throw
  ] when ;

: receive-if ( pred -- message )
  #! Return the first message frmo the current processes mailbox
  #! that satisfies the predicate. To satisfy the predicate, 'pred' 
  #! is called  with the item on the stack and the predicate should leave
  #! a boolean indicating whether it was satisfied or not. The predicate
  #! must have stack effect ( X -- bool ). If nothing in the mailbox 
  #! satisfies the predicate then the process will block until something does.
  self process-mailbox mailbox-get? dup linked-exception? [
    linked-exception-error throw
  ] when ; 

: rethrow-linked ( error -- )
  #! Rethrow the error to the linked process
  self process-links [ over <linked-exception> swap send ] each drop ;

: spawn-link ( quot -- process )
  #! Same as spawn but if the quotation throws an error that
  #! is uncaught, that error gets propogated to the process
  #! performing the spawn-link.
  [ catch [ rethrow-linked ] when* ] cons
  [ in-thread ] self make-linked-process [ with-process ] over slip ;

#! A common operation is to send a message to a process containing
#! the sending process so the receiver can send a reply back. A 'tag'
#! is also sent so that the sender can match the reply with the
#! original request. The 'tagged-message' tuple ecapsulates this.
TUPLE: tagged-message data from tag ;

: >tagged-message< ( tagged-message -- data from tag )
  #! Explode a message tuple.
  dup tagged-message-data swap
  dup tagged-message-from swap
  tagged-message-tag ;

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

: tag-message ( message -- tagged-message )
  #! Given a message, wrap it with a tagged message.
  self gensym <tagged-message> ;

: tag-match? ( message tag -- bool )
  #! Return true if the message is a tagged message and
  #! its tag matches the given tag.
  swap dup tagged-message? [
    tagged-message-tag =
  ] [
    2drop f
  ] ifte ;

: send-synchronous ( message process -- reply )
  #! Sends a message to the process using the 'message' 
  #! protocol and waits for a reply to that message. The reply
  #! is matched up with the request by generating a message tag
  #! which should be sent back with the reply.
  >r tag-message [ tagged-message-tag ] keep r> send
  unit [ car tag-match? ] cons receive-if tagged-message-data ;

: reply ( tagged-message message -- )
  #! Replies to the tagged-message which should have been a result of a 
  #! 'send-synchronous' call. It will send 'message' back to the process
  #! that originally sent the tagged message, and will have the same tag
  #! as that in 'tagged-message'.
  swap >tagged-message< rot drop  ( message from tag )
  swap >r >r self r> <tagged-message> r> send ;

: forever ( quot -- )
  #! Loops forever executing the quotation.
  dup >r call r> forever ; 

SYMBOL: quit-cc

: (spawn-server) ( quot -- )
  #! Receive a message, and run 'quot' on it. If 'quot' 
  #! returns true, start again, otherwise exit loop.
  #! The quotation should have stack effect ( message -- bool ).
  "Waiting for message in server: " write self process-pid print
  receive over call [ (spawn-server) ] when ;

: spawn-server ( quot -- process )
  #! Spawn a server that receives messages, calling the
  #! quotation on the message. If the quotation returns false
  #! the spawned process exits. If it returns true, the process
  #! starts from the beginning again. The quotation should have
  #! stack effect ( message -- bool ).
  [  
    (spawn-server)
    "Exiting process: " write self process-pid print
  ] cons spawn ;

: spawn-linked-server ( quot -- process )
  #! Similar to 'spawn-server' but the parent process will be linked
  #! to the child.
  [  
    (spawn-server)
    "Exiting process: " write self process-pid print
  ] cons spawn-link ;

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
  >r >r >tagged-message< rot ( from tag data r: quot pred )
  dup r> call [   ( from tag data r: quot )
    r> call       ( from tag result )
    self          ( from tag result self )
    rot           ( from self tag result )
    <tagged-message> swap send
  ] [
    r> drop 3drop
  ] ifte ;

: maybe-send-reply ( message pred quot -- )
  #! Same as !result but if false is returned from
  #! quot then nothing is sent back to the caller.
  >r >r >tagged-message< rot ( from tag data r: quot pred )
  dup r> call [   ( from tag data r: quot )
    r> call       ( from tag result )
    [
      self          ( from tag result self )
      rot           ( from self tag result )
      <tagged-message> swap send
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
  [ ] callcc1 dup process? [ self-process set f ] when ;
  
: call-server-cc ( server-cc -- )
  #! Calls the server continuation passing the current 'self'
  #! so the server continuation gets its new self updated.
  self swap call ;

: future ( quot -- future )
  #! Spawn a process to call the quotation and immediately return
  #! a 'future' on the stack. The future can later be queried with
  #! ?future. If the quotation has completed the result will be returned.
  #! If not, the process will block until the quotation completes.
  #! 'quot' must have stack effect ( -- X ).
  [ call self send ] cons spawn ;

: ?future ( future -- result )
  #! Block the process until the future has completed and then place the
  #! result on the stack. Return the result immediately if the future has completed.
  process-mailbox mailbox-get ;

TUPLE: promise fulfilled? value processes ;

C: promise ( -- <promise> )
  [ 0 <vector> swap set-promise-processes ] keep ;

: fulfill ( value promise  -- )
  #! Set the future of the promise to the given value. Threads
  #! blocking on the promise will then be released.
  dup promise-fulfilled? [
    [ set-promise-value ] keep
    [ t swap set-promise-fulfilled? ] keep    
    [ promise-processes ] keep 0 <vector> swap set-promise-processes
    [ schedule-thread ] each yield 
  ] unless ;

 : (maybe-block-promise) ( promise -- promise )  
  #! Block the process if the promise is unfulfilled. This is different from
  #! (mailbox-block-if-empty) in that when a promise is fulfilled, all threads
  #! need to be resumed, rather than just one.
  dup promise-fulfilled? [
    [
      swap promise-processes push stop      
    ] callcc0 
  ] unless ;

: ?promise ( promise -- result ) 
  (maybe-block-promise) promise-value ;
  
! ******************************
! Experimental code below
! ******************************
SYMBOL: lazy-quot

: lazy ( quot -- lazy )
  #! Spawn a process that immediately blocks and return it. 
  #! When '?lazy' is called on the returned process, call the quotation
  #! and return the result. The quotation must have stack effect ( -- X ).
  [
    [
      lazy-quot set      
      [
        [ tagged-message? [ [ drop t ] [ get call ] send-reply ] ]
      ] recv
    ] with-scope
  ] cons spawn ;

: ?lazy ( lazy -- result )
  #! Given a process spawned using 'lazy', evaluate it and return the result.
  lazy-quot swap send-synchronous ;

