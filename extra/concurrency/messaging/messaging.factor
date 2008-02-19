! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
!
! Concurrency library for Factor based on Erlang/Termite style
! concurrency.
IN: concurrency.messaging
USING: dlists threads sequences continuations
namespaces random math quotations words kernel arrays assocs
init system concurrency.conditions ;

TUPLE: mailbox threads data ;

: <mailbox> ( -- mailbox )
    <dlist> <dlist> \ mailbox construct-boa ;

: mailbox-empty? ( mailbox -- bool )
    mailbox-data dlist-empty? ;

: mailbox-put ( obj mailbox -- )
    [ mailbox-data push-front ] keep
    mailbox-threads notify-all ;

<PRIVATE

: block-unless-pred ( pred mailbox timeout -- )
    2over mailbox-data dlist-contains? [
        3drop
    ] [
        2dup >r mailbox-threads r> "mailbox" wait
        block-unless-pred
    ] if ; inline

: block-if-empty ( mailbox timeout -- mailbox )
    over mailbox-empty? [
        2dup >r mailbox-threads r> "mailbox" wait
        block-if-empty
    ] [
        drop
    ] if ;

PRIVATE>

: mailbox-peek ( mailbox -- obj )
    mailbox-data peek-back ;

: mailbox-get-timeout ( mailbox timeout -- obj )
    block-if-empty mailbox-data pop-back ;

: mailbox-get ( mailbox -- obj )
    f mailbox-get-timeout ;

: mailbox-get-all-timeout ( mailbox timeout -- array )
    block-if-empty
    [ dup mailbox-empty? ]
    [ dup mailbox-data pop-back ]
    [ ] unfold nip ;

: mailbox-get-all ( mailbox -- array )
    f mailbox-get-all-timeout ;

: while-mailbox-empty ( mailbox quot -- )
    over mailbox-empty? [
        dup >r swap slip r> while-mailbox-empty
    ] [
        2drop
    ] if ; inline

: mailbox-timeout-get? ( pred mailbox timeout -- obj )
    [ block-unless-pred ] 3keep drop
    mailbox-data delete-node-if ; inline

: mailbox-get? ( pred mailbox -- obj )
    f mailbox-timeout-get? ; inline

TUPLE: linked error thread ;

C: <linked> linked

GENERIC: send ( message process -- )

: mailbox-of ( thread -- mailbox )
    dup thread-mailbox [ ] [
        <mailbox> dup rot set-thread-mailbox
    ] ?if ;

M: thread send ( message thread -- )
    mailbox-of mailbox-put ;

: ?linked dup linked? [ rethrow ] when ;

: mailbox self mailbox-of ;

: receive ( -- message )
    mailbox mailbox-get ?linked ;

: receive-if ( pred -- message )
    mailbox mailbox-get? ?linked ; inline

: rethrow-linked ( error process supervisor -- )
    >r <linked> r> send ;

: spawn-linked-to ( quot name mailbox -- thread )
    [ >r <linked> r> mailbox-put ] curry <thread>
    [ (spawn) ] keep ;

: spawn-linked ( quot name -- thread )
    mailbox spawn-linked-to ;

TUPLE: synchronous data sender tag ;

: <synchronous> ( data -- sync )
    self random-256 synchronous construct-boa ;

TUPLE: reply data tag ;

: <reply> ( data synchronous -- reply )
    synchronous-tag \ reply construct-boa ;

: send-synchronous ( message thread -- reply )
    >r <synchronous> dup r> send [
        over reply? [
            >r reply-tag r> synchronous-tag =
        ] [
            2drop f
        ] if
    ] curry receive-if reply-data ;

: reply-synchronous ( message synchronous -- )
    [ <reply> ] keep synchronous-sender send ;

<PRIVATE

: remote-processes ( -- hash )
   \ remote-processes get-global ;

PRIVATE>

: register-process ( name process -- )
    swap remote-processes set-at ;

: unregister-process ( name -- )
    remote-processes delete-at ;

: get-process ( name -- process )
    dup remote-processes at [ ] [ thread ] ?if ;

\ remote-processes global [ H{ } assoc-like ] change-at
