! Copyright (C) 2005, 2010 Chris Double, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes kernel kernel.private
namespaces summary threads ;
IN: concurrency.messaging

GENERIC: send ( message thread -- )

GENERIC: mailbox-of ( thread -- mailbox )

M: thread mailbox-of
    [ mailbox>> ]
    [ { mailbox } declare ]
    [ <mailbox> [ >>mailbox drop ] keep ] ?if ; inline

M: thread send
    mailbox-of mailbox-put ;

: my-mailbox ( -- mailbox ) self mailbox-of ; inline

: receive ( -- message )
    my-mailbox mailbox-get ?linked ;

: receive-timeout ( timeout -- message )
    [ my-mailbox ] dip mailbox-get-timeout ?linked ;

: receive-if ( pred -- message )
    [ my-mailbox ] dip mailbox-get? ?linked ; inline

: receive-if-timeout ( timeout pred -- message )
    [ my-mailbox ] 2dip mailbox-get-timeout? ?linked ; inline

: rethrow-linked ( error process supervisor -- )
    [ <linked-error> ] dip send ;

: spawn-linked ( quot name -- thread )
    my-mailbox spawn-linked-to ;

TUPLE: synchronous data sender tag ;

: <synchronous> ( data -- sync )
    self synchronous counter synchronous boa ;

TUPLE: reply data tag ;

: <reply> ( data synchronous -- reply )
    tag>> \ reply boa ;

: synchronous-reply? ( response synchronous -- ? )
    over reply? [ [ tag>> ] same? ] [ 2drop f ] if ;

ERROR: cannot-send-synchronous-to-self message thread ;

M: cannot-send-synchronous-to-self summary
    drop "Cannot synchronous send to myself" ;

: send-synchronous ( message thread -- reply )
    dup self eq? [
        cannot-send-synchronous-to-self
    ] [
        [ <synchronous> dup ] dip send
        '[ _ synchronous-reply? ] receive-if
        data>>
    ] if ;

: reply-synchronous ( message synchronous -- )
    [ <reply> ] keep sender>> send ;

: handle-synchronous ( quot: ( ... message -- ... reply ) -- )
    receive [
        data>> swap call
    ] keep reply-synchronous ; inline
