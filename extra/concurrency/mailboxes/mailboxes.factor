! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: concurrency.mailboxes
USING: dlists threads sequences continuations
namespaces random math quotations words kernel arrays assocs
init system concurrency.conditions ;

TUPLE: mailbox threads data ;

: <mailbox> ( -- mailbox )
    <dlist> <dlist> mailbox construct-boa ;

: mailbox-empty? ( mailbox -- bool )
    mailbox-data dlist-empty? ;

: mailbox-put ( obj mailbox -- )
    [ mailbox-data push-front ] keep
    mailbox-threads notify-all yield ;

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

: mailbox-get-timeout? ( pred mailbox timeout -- obj )
    [ block-unless-pred ] 3keep drop
    mailbox-data delete-node-if ; inline

: mailbox-get? ( pred mailbox -- obj )
    f mailbox-get-timeout? ; inline

TUPLE: linked error thread ;

C: <linked> linked

: ?linked dup linked? [ rethrow ] when ;

: spawn-linked-to ( quot name mailbox -- thread )
    [ >r <linked> r> mailbox-put ] curry <thread>
    [ (spawn) ] keep ;
