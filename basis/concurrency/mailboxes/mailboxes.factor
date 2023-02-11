! Copyright (C) 2005, 2010 Chris Double, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.conditions continuations deques
destructors dlists kernel sequences threads vocabs.loader ;
IN: concurrency.mailboxes

TUPLE: mailbox { threads dlist } { data dlist } ;

: <mailbox> ( -- mailbox )
    mailbox new
        <dlist> >>threads
        <dlist> >>data ; inline

: mailbox-empty? ( mailbox -- bool )
    data>> deque-empty? ; inline

GENERIC: mailbox-put ( obj mailbox -- )

M: mailbox mailbox-put
    [ data>> push-front ]
    [ threads>> notify-all ] bi yield ;

: wait-for-mailbox ( mailbox timeout -- )
    [ threads>> ] dip "mailbox" wait ; inline

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
    ] if ; inline recursive

: mailbox-peek ( mailbox -- obj )
    data>> peek-back ;

GENERIC#: mailbox-get-timeout 1 ( mailbox timeout -- obj )

M: mailbox mailbox-get-timeout block-if-empty data>> pop-back ;

: mailbox-get ( mailbox -- obj )
    f mailbox-get-timeout ; inline

: mailbox-get-all-timeout ( mailbox timeout -- seq )
    block-if-empty data>> [ ] collector [ slurp-deque ] dip ;

: mailbox-get-all ( mailbox -- seq )
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
    '[
        _ 2dup wait-for-mailbox wait-for-close-timeout
    ] unless-disposed ;

: wait-for-close ( mailbox -- )
    f wait-for-close-timeout ;

TUPLE: linked-error error thread ;

C: <linked-error> linked-error

: ?linked ( message -- message )
    dup linked-error? [ rethrow ] when ;

TUPLE: linked-thread < thread supervisor ;

M: linked-thread error-in-thread
    [ <linked-error> ] [ supervisor>> ] bi mailbox-put stop ;

: <linked-thread> ( quot name mailbox -- thread' )
    [ linked-thread new-thread ] dip >>supervisor ;

: spawn-linked-to ( quot name mailbox -- thread )
    <linked-thread> [ (spawn) ] keep ;

{ "concurrency.mailboxes" "debugger" } "concurrency.mailboxes.debugger" require-when
