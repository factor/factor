! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
!
! Concurrency library for Factor based on Erlang/Termite style
! concurrency.
IN: concurrency.messaging
USING: dlists concurrency.threads sequences continuations
namespaces random math quotations words kernel arrays assocs
init system ;

TUPLE: mailbox threads data ;

: <mailbox> ( -- mailbox )
    <dlist> <dlist> mailbox construct-boa ;

: mailbox-empty? ( mailbox -- bool )
    mailbox-data dlist-empty? ;

: notify-all ( dlist -- )
    [ second resume ] dlist-slurp yield ;

: mailbox-put ( obj mailbox -- )
    [ mailbox-data push-front ] keep
    mailbox-threads notify-all ;

<PRIVATE

: mailbox-wait ( mailbox timeout -- mailbox timeout )
    [ 2array swap mailbox-threads push-front ] suspend drop ;
    inline

: block-unless-pred ( pred mailbox timeout -- )
    2over mailbox-data dlist-contains? [
        3drop
    ] [
        mailbox-wait block-unless-pred
    ] if ; inline

: block-if-empty ( mailbox timeout -- mailbox )
    over mailbox-empty? [
        mailbox-wait block-if-empty
    ] [
        drop
    ] if ;

PRIVATE>

: mailbox-peek ( mailbox -- obj )
    mailbox-data peek-front ;

: mailbox-get-timeout ( mailbox timeout -- obj )
    block-if-empty mailbox-data pop-front ;

: mailbox-get ( mailbox -- obj )
    f mailbox-timeout-get ;

: mailbox-get-all-timeout ( mailbox timeout -- array )
    (mailbox-block-if-empty)
    [ dup mailbox-empty? ]
    [ dup mailbox-data pop-back ]
    [ ] unfold nip ;

: mailbox-get-all ( mailbox -- array )
    f mailbox-timeout-get-all ;

: while-mailbox-empty ( mailbox quot -- )
    over mailbox-empty? [
        dup >r swap slip r> while-mailbox-empty
    ] [
        2drop
    ] if ; inline

: mailbox-timeout-get? ( pred mailbox timeout -- obj )
    [ (mailbox-block-unless-pred) ] 3keep drop
    mailbox-data delete-node-if ; inline

: mailbox-get? ( pred mailbox -- obj )
    f mailbox-timeout-get? ;

TUPLE: linked error thread ;

: <linked> self linked construct-boa ;

GENERIC: send ( message thread -- )

M: thread send ( message thread -- )
    thread-mailbox mailbox-put ;

: ?linked dup linked? [ rethrow ] when ;

: mailbox self thread-mailbox ;

: receive ( -- message )
    mailbox mailbox-get ?linked ;

: receive-if ( pred -- message )
    mailbox mailbox-get? ?linked ; inline

: rethrow-linked ( error supervisor -- )
    >r <linked> r> send ;

: spawn-linked ( quot name -- thread )
    self [ rethrow-linked ] curry <thread> [ (spawn) ] keep ;

TUPLE: synchronous data sender tag ;

: <synchronous> ( data -- sync )
    self random-256 synchronous construct-boa ;

TUPLE: reply data tag ;

: <reply> ( data synchronous -- reply )
    synchronous-tag \ reply construct-boa ;

: send-synchronous ( message thread -- reply )
    >r <synchronous> dup r> send
    [ over reply? [ reply-tag = ] [ 2drop f ] if ] curry
    receive-if reply-data ;

: reply-synchronous ( message synchronous -- )
    [ <reply> ] keep synchronous-sender reply ;
