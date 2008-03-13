! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
!
! Concurrency library for Factor, based on Erlang/Termite style
! concurrency.
USING: kernel threads concurrency.mailboxes continuations
namespaces assocs random ;
IN: concurrency.messaging

GENERIC: send ( message thread -- )

: mailbox-of ( thread -- mailbox )
    dup thread-mailbox [ ] [
        <mailbox> dup rot set-thread-mailbox
    ] ?if ;

M: thread send ( message thread -- )
    check-registered mailbox-of mailbox-put ;

: my-mailbox self mailbox-of ;

: receive ( -- message )
    my-mailbox mailbox-get ?linked ;

: receive-timeout ( timeout -- message )
    my-mailbox swap mailbox-get-timeout ?linked ;

: receive-if ( pred -- message )
    my-mailbox mailbox-get? ?linked ; inline

: receive-if-timeout ( pred timeout -- message )
    my-mailbox swap mailbox-get-timeout? ?linked ; inline

: rethrow-linked ( error process supervisor -- )
    >r <linked-error> r> send ;

: spawn-linked ( quot name -- thread )
    my-mailbox spawn-linked-to ;

TUPLE: synchronous data sender tag ;

: <synchronous> ( data -- sync )
    self random-256 synchronous construct-boa ;

TUPLE: reply data tag ;

: <reply> ( data synchronous -- reply )
    synchronous-tag \ reply construct-boa ;

: synchronous-reply? ( response synchronous -- ? )
    over reply?
    [ >r reply-tag r> synchronous-tag = ]
    [ 2drop f ] if ;

: send-synchronous ( message thread -- reply )
    dup self eq? [
        "Cannot synchronous send to myself" throw
    ] [
        >r <synchronous> dup r> send
        [ synchronous-reply? ] curry receive-if
        reply-data
    ] if ;

: reply-synchronous ( message synchronous -- )
    [ <reply> ] keep synchronous-sender send ;

: handle-synchronous ( quot -- )
    receive [
        synchronous-data swap call
    ] keep reply-synchronous ; inline

<PRIVATE

: registered-processes ( -- hash )
   \ registered-processes get-global ;

PRIVATE>

: register-process ( name process -- )
    swap registered-processes set-at ;

: unregister-process ( name -- )
    registered-processes delete-at ;

: get-process ( name -- process )
    dup registered-processes at [ ] [ thread ] ?if ;

\ registered-processes global [ H{ } assoc-like ] change-at
