! Copyright (C) 2005, 2010 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists deques threads sequences continuations namespaces
math quotations words kernel arrays assocs init system
concurrency.conditions accessors debugger debugger.threads
locals fry ;
IN: concurrency.mailboxes

TUPLE: mailbox threads data ;

: <mailbox> ( -- mailbox )
    mailbox new
        <dlist> >>threads
        <dlist> >>data ;

: mailbox-empty? ( mailbox -- bool )
    data>> deque-empty? ;

: mailbox-put ( obj mailbox -- )
    [ data>> push-front ]
    [ threads>> notify-all ] bi yield ;

: wait-for-mailbox ( mailbox timeout -- )
    [ threads>> ] dip "mailbox" wait ;

:: block-unless-pred ( ... mailbox timeout pred: ( ... message -- ... ? ) -- ... )
    mailbox data>> pred dlist-any? [
        mailbox timeout wait-for-mailbox
        mailbox timeout pred block-unless-pred
    ] unless ; inline recursive

: block-if-empty ( mailbox timeout -- mailbox )
    over mailbox-empty? [
        2dup wait-for-mailbox block-if-empty
    ] [
        drop
    ] if ;

: mailbox-peek ( mailbox -- obj )
    data>> peek-back ;

: mailbox-get-timeout ( mailbox timeout -- obj )
    block-if-empty data>> pop-back ;

: mailbox-get ( mailbox -- obj )
    f mailbox-get-timeout ;

: mailbox-get-all-timeout ( mailbox timeout -- array )
    block-if-empty
    [ dup mailbox-empty? not ]
    [ dup data>> pop-back ]
    produce nip ;

: mailbox-get-all ( mailbox -- array )
    f mailbox-get-all-timeout ;

: while-mailbox-empty ( mailbox quot -- )
    [ '[ _ mailbox-empty? ] ] dip while ; inline

: mailbox-get-timeout? ( mailbox timeout pred -- obj )
    [ block-unless-pred ]
    [ [ drop data>> ] dip delete-node-if ]
    3bi ; inline

: mailbox-get? ( mailbox pred -- obj )
    f swap mailbox-get-timeout? ; inline

: wait-for-close-timeout ( mailbox timeout -- )
    over disposed>>
    [ 2drop ] [ 2dup wait-for-mailbox wait-for-close-timeout ] if ;

: wait-for-close ( mailbox -- )
    f wait-for-close-timeout ;

TUPLE: linked-error error thread ;

M: linked-error error.
    [ thread>> error-in-thread. ] [ error>> error. ] bi ;

C: <linked-error> linked-error

: ?linked ( message -- message )
    dup linked-error? [ rethrow ] when ;

TUPLE: linked-thread < thread supervisor ;

M: linked-thread error-in-thread
    [ <linked-error> ] [ supervisor>> ] bi mailbox-put ;

: <linked-thread> ( quot name mailbox -- thread' )
    [ linked-thread new-thread ] dip >>supervisor ;

: spawn-linked-to ( quot name mailbox -- thread )
    <linked-thread> [ (spawn) ] keep ;
