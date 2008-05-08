! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: concurrency.mailboxes
USING: dlists threads sequences continuations
namespaces random math quotations words kernel arrays assocs
init system concurrency.conditions accessors debugger ;

TUPLE: mailbox threads data closed ;

: check-closed ( mailbox -- )
    closed>> [ "Mailbox closed" throw ] when ; inline

M: mailbox dispose
    t >>closed threads>> notify-all ;

: <mailbox> ( -- mailbox )
    <dlist> <dlist> f mailbox boa ;

: mailbox-empty? ( mailbox -- bool )
    data>> dlist-empty? ;

: mailbox-put ( obj mailbox -- )
    [ data>> push-front ]
    [ threads>> notify-all ] bi yield ;

: wait-for-mailbox ( mailbox timeout -- )
    >r threads>> r> "mailbox" wait ;

: block-unless-pred ( mailbox timeout pred -- )
    pick check-closed
    pick data>> over dlist-contains? [
        3drop
    ] [
        >r 2dup wait-for-mailbox r> block-unless-pred
    ] if ; inline

: block-if-empty ( mailbox timeout -- mailbox )
    over check-closed
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
    [ dup mailbox-empty? ]
    [ dup data>> pop-back ]
    [ ] unfold nip ;

: mailbox-get-all ( mailbox -- array )
    f mailbox-get-all-timeout ;

: while-mailbox-empty ( mailbox quot -- )
    over mailbox-empty? [
        dup >r swap slip r> while-mailbox-empty
    ] [
        2drop
    ] if ; inline

: mailbox-get-timeout? ( mailbox timeout pred -- obj )
    3dup block-unless-pred
    nip >r data>> r> delete-node-if ; inline

: mailbox-get? ( mailbox pred -- obj )
    f swap mailbox-get-timeout? ; inline

: wait-for-close-timeout ( mailbox timeout -- )
    over closed>>
    [ 2drop ] [ 2dup wait-for-mailbox wait-for-close-timeout ] if ;

: wait-for-close ( mailbox -- )
    f wait-for-close-timeout ;

TUPLE: linked-error error thread ;

M: linked-error error.
    [ thread>> error-in-thread. ] [ error>> error. ] bi ;

C: <linked-error> linked-error

: ?linked dup linked-error? [ rethrow ] when ;

TUPLE: linked-thread < thread supervisor ;

M: linked-thread error-in-thread
    [ <linked-error> ] [ supervisor>> ] bi mailbox-put ;

: <linked-thread> ( quot name mailbox -- thread' )
    >r linked-thread new-thread r> >>supervisor ;

: spawn-linked-to ( quot name mailbox -- thread )
    <linked-thread> [ (spawn) ] keep ;
