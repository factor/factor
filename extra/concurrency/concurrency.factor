! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Concurrency library for Factor based on Erlang/Termite style
! concurrency.
USING: vectors dlists threads sequences continuations
       namespaces random math quotations words kernel match
       arrays io assocs init ;
IN: concurrency

TUPLE: mailbox threads data ;

: make-mailbox ( -- mailbox )
    V{ } clone <dlist> mailbox construct-boa ;

: mailbox-empty? ( mailbox -- bool )
    mailbox-data dlist-empty? ;

: mailbox-put ( obj mailbox -- )
    [ mailbox-data dlist-push-end ] keep
    [ mailbox-threads ] keep 0 <vector> swap set-mailbox-threads
    [ schedule-thread ] each yield ;

<PRIVATE
: (mailbox-block-unless-pred) ( pred mailbox -- )
    2dup mailbox-data dlist-contains? [
        2drop
    ] [
        [ swap mailbox-threads push stop ] callcc0
        (mailbox-block-unless-pred)
    ] if ; inline

: (mailbox-block-if-empty) ( mailbox -- mailbox2 )
    dup mailbox-empty? [
        [ swap mailbox-threads push stop ] callcc0
        (mailbox-block-if-empty)
    ] when ;
PRIVATE>
: mailbox-get ( mailbox -- obj )
    (mailbox-block-if-empty)
    mailbox-data dlist-pop-front ;

<PRIVATE
: (mailbox-get-all) ( mailbox -- )
    dup mailbox-empty? [
        drop
    ] [
        dup mailbox-data dlist-pop-front , (mailbox-get-all)
    ] if ;
PRIVATE>
: mailbox-get-all ( mailbox -- array )
    (mailbox-block-if-empty)
    [ (mailbox-get-all) ] { } make ;

: while-mailbox-empty ( mailbox quot -- )
    over mailbox-empty? [
        dup >r swap slip r> while-mailbox-empty
    ] [
        2drop
    ] if ; inline

: mailbox-get? ( pred mailbox -- obj )
    2dup (mailbox-block-unless-pred)
    mailbox-data dlist-remove ;
    inline

TUPLE: process links pid mailbox ;

C: <process> process

GENERIC: send ( message process -- )

: random-64 ( -- id )
    #! Generate a random id to use for pids
    "ID" 64 [ drop 10 random CHAR: 0 + ] map append ;

<PRIVATE
: make-process ( -- process )
    #! Return a process set to run on the local node. A process is
    #! similar to a thread but can send and receive messages to and
    #! from other processes. It may also be linked to other processes so
    #! that it receives a message if that process terminates.
    [ ] random-64 make-mailbox <process> ;

: make-linked-process ( process -- process )
    #! Return a process set to run on the local node. That process is
    #! linked to the process on the stack. It will receive a message if
    #! that process terminates.
    1quotation random-64 make-mailbox <process> ;
PRIVATE>

: self ( -- process )
    \ self get  ;

<PRIVATE
: init-main-process ( -- )
    #! Setup the main process.
    make-process \ self set-global ;

: with-process ( quot process -- )
    #! Calls the quotation with 'self' set
    #! to the given process.
    \ self rot with-variable ; inline

PRIVATE>

DEFER: register-process
DEFER: unregister-process

<PRIVATE
: ((spawn)) ( quot -- )
    self dup process-pid swap register-process
    [ self process-pid unregister-process ] [ ] cleanup ; inline

: (spawn) ( quot -- process )
    [ in-thread ] make-process [ with-process ] keep ; inline

PRIVATE>

: spawn ( quot -- process )
    [ ((spawn)) ] curry (spawn) ; inline

TUPLE: linked-exception error ;

C: <linked-exception> linked-exception

: while-no-messages ( quot -- )
    #! Run the quotation in a loop while no messages are in
    #! the processes mailbox. The quot should have stack effect
    #! ( -- ).
    >r self process-mailbox r> while-mailbox-empty ; inline

M: process send ( message process -- )
    process-mailbox mailbox-put ;

: receive ( -- message )
    self process-mailbox mailbox-get dup linked-exception? [
        linked-exception-error throw
    ] when ;

: receive-if ( pred -- message )
    self process-mailbox mailbox-get? dup linked-exception? [
        linked-exception-error throw
    ] when ; inline

: rethrow-linked ( error -- )
    #! Rethrow the error to the linked process
    self process-links [
        over <linked-exception> swap send
    ] each drop ;

<PRIVATE
: (spawn-link) ( quot -- process )
    [ in-thread ] self make-linked-process
    [ with-process ] keep ; inline
PRIVATE>

: spawn-link ( quot -- process )
    [ catch [ rethrow-linked ] when* ] curry
    [ ((spawn)) ] curry (spawn-link) ; inline

<PRIVATE
: (recv) ( msg form -- )
    #! Process a form with the following format:
    #!   [ pred match-quot ]
    #! 'pred' is a word that has stack effect ( msg -- bool ). It is
    #! executed with the message on the stack. It should return a
    #! boolean if it is a message this form should process.
    #! 'match-quot' is a quotation with stack effect ( msg -- ). It
    #! will be called with the message on the top of the stack if
    #! the 'pred' word returned true.
    [ first execute ] 2keep rot [ second call ] [ 2drop ] if ;
PRIVATE>

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

MATCH-VARS: ?from ?tag ;

<PRIVATE
: tag-message ( message -- tagged-message )
    #! Given a message, wrap it with the sending process and a unique tag.
    >r self random-64 r> 3array ;
PRIVATE>

: send-synchronous ( message process -- reply )
    #! Sends a message to the process synchronously. The
    #! message will be wrapped to include the process of the sender
    #! and a unique tag. After being sent the sending process will
    #! block for a reply tagged with the same unique tag.
    >r tag-message dup r> send second _ 2array [ match ] curry
    receive-if second ;

<PRIVATE
: forever ( quot -- )
    #! Loops forever executing the quotation.
    dup slip forever ;

SYMBOL: quit-cc

: (spawn-server) ( quot -- )
    #! Receive a message, and run 'quot' on it. If 'quot'
    #! returns true, start again, otherwise exit loop.
    #! The quotation should have stack effect ( message -- bool ).
    "Waiting for message in server: " write
    self process-pid print
    receive over call [ (spawn-server) ] when ;
PRIVATE>

: spawn-server ( quot -- process )
    #! Spawn a server that receives messages, calling the
    #! quotation on the message. If the quotation returns false
    #! the spawned process exits. If it returns true, the process
    #! starts from the beginning again. The quotation should have
    #! stack effect ( message -- bool ).
    [
        (spawn-server)
        "Exiting process: " write self process-pid print
    ] curry spawn ;

: spawn-linked-server ( quot -- process )
    #! Similar to 'spawn-server' but the parent process will be linked
    #! to the child.
    [
        (spawn-server)
        "Exiting process: " write self process-pid print
    ] curry spawn-link ;

: server-cc ( -- cc|process )
    #! Captures the current continuation and returns the value.
    #! If that CC is called with a process on the stack it will
    #! set 'self' for the current process to it. Otherwise it will
    #! return the value. This allows capturing a continuation in a server,
    #! and jumping back into it from a spawn and keeping the 'self'
    #! variable correct. It's a workaround until I can find out how to
    #! stop 'self' from being clobbered back to its old value.
    [ ] callcc1 dup process? [ \ self set-global f ] when ;

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
    [ self send ] compose spawn ;

: ?future ( future -- result )
    #! Block the process until the future has completed and then
    #! place the result on the stack. Return the result
    #! immediately if the future has completed.
    process-mailbox mailbox-get ;

: parallel-map ( seq quot -- newseq )
    #! Spawn a process to apply quot to each element of seq,
    #! joining the results into a sequence at the end.
    [ curry future ] curry map [ ?future ] map ;

: parallel-each ( seq quot -- )
    #! Spawn a process to apply quot to each element of seq,
    #! and waits for all processes to complete.
    [ f ] compose parallel-map drop ;

TUPLE: promise fulfilled? value processes ;

: <promise> ( -- <promise> )
    f f V{ } clone promise construct-boa ;

: fulfill ( value promise  -- )
    #! Set the future of the promise to the given value. Threads
    #! blocking on the promise will then be released.
    dup promise-fulfilled? [ 
        2drop
    ] [
        [ set-promise-value ] keep
        [ t swap set-promise-fulfilled? ] keep
        [ promise-processes ] keep
        0 <vector> swap set-promise-processes
        [ schedule-thread ] each yield
    ] if ;

<PRIVATE
 : (maybe-block-promise) ( promise -- promise )
    #! Block the process if the promise is unfulfilled. This is different from
    #! (mailbox-block-if-empty) in that when a promise is fulfilled, all threads
    #! need to be resumed, rather than just one.
    dup promise-fulfilled? [
        [ swap promise-processes push stop ] callcc0
    ] unless ;
PRIVATE>

: ?promise ( promise -- result )
    (maybe-block-promise) promise-value ;

! ******************************
! Experimental code below
! ******************************
<PRIVATE
: (lazy) ( v -- )
    receive {
        { { ?from ?tag _ }
            [ ?tag over 2array ?from send (lazy) ] }
    } match-cond ;
PRIVATE>

: lazy ( quot -- lazy )
    #! Spawn a process that immediately blocks and return it.
    #! When '?lazy' is called on the returned process, call the quotation
    #! and return the result. The quotation must have stack effect ( -- X ).
    [
        receive {
            { { ?from ?tag _ }
                [ call ?tag over 2array ?from send (lazy) ] }
        } match-cond
    ] spawn nip ;

: ?lazy ( lazy -- result )
    #! Given a process spawned using 'lazy', evaluate it and return the result.
    f swap send-synchronous ;

<PRIVATE
: remote-processes ( -- hash )
   \ remote-processes get-global ;
PRIVATE>

: register-process ( name process -- )
    swap remote-processes set-at ;

: unregister-process ( name -- )
    remote-processes delete-at ;

: get-process ( name -- process )
    remote-processes at ;

[
    H{ } clone \ remote-processes set-global
    init-main-process
    self [ process-pid ] keep register-process
] "process-registry" add-init-hook
