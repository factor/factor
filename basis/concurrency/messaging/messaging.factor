! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel threads concurrency.mailboxes continuations
namespaces assocs accessors summary fry calendar math sequences ;
IN: concurrency.messaging

TUPLE: envelope data sender tag expiry ;

<PRIVATE

: new-envelope ( data class -- envelope )
    new swap >>data self >>sender ;

: <envelope> ( data -- envelope )
    dup envelope?
    [ envelope new-envelope ] unless ;

: expired? ( message -- ? )
    dup envelope?
    [ expiry>>
      [ now (time-) 0 < ]
      [ f ] if*
    ] [ drop f ] if ; inline

: if-expired ( message quot -- message )
    [ dup expired? ] dip
    '[ drop _ call( -- message ) ] [ ] if ; inline

PRIVATE>

GENERIC: send ( message thread -- )

GENERIC: send-timeout ( timeout message thread -- )

: mailbox-of ( thread -- mailbox )
    dup mailbox>> [ ] [
        <mailbox> [ >>mailbox drop ] keep
    ] ?if ;

M: thread send ( message thread -- )
    [ <envelope> ] dip
    check-registered mailbox-of mailbox-put ;

M: thread send-timeout ( timeout message thread -- )
    [ <envelope> swap hence >>expiry ] dip send ; 

: my-mailbox ( -- mailbox ) self mailbox-of ;

: (receive) ( -- message )
    my-mailbox mailbox-get ?linked
    [ (receive) ] if-expired ;  

: receive ( -- message )
    (receive) data>> ;
    
: (receive-timeout) ( timeout -- message )
    [ my-mailbox ] dip
    [ mailbox-get-timeout ?linked ] keep
    '[ _ (receive-timeout) ] if-expired ; inline

: receive-timeout ( timeout -- message )
    (receive-timeout) data>> ;

: (receive-if) ( pred -- message )
    [ my-mailbox ] dip
    [ mailbox-get? ?linked ] keep
    '[ _ (receive-if) ] if-expired ; inline

: receive-if ( pred -- message )
    [ data>> ] prepend (receive-if) data>> ; inline

: (receive-if-timeout) ( timeout pred -- message )
    [ my-mailbox ] 2dip
    [ mailbox-get-timeout? ?linked ] 2keep
    '[ _ _ (receive-if-timeout) ] if-expired ; inline

: receive-if-timeout ( timeout pred -- message )
    [ data>> ] prepend 
    (receive-if-timeout) data>> ; inline

: rethrow-linked ( error process supervisor -- )
    [ <linked-error> ] dip send ;

: spawn-linked ( quot name -- thread )
    my-mailbox spawn-linked-to ;

TUPLE: synchronous < envelope ;

: <synchronous> ( data -- sync )
    synchronous new-envelope 
    synchronous counter >>tag ;

TUPLE: reply < envelope ;

: <reply> ( data synchronous -- reply )
    [ reply new-envelope ] dip
    tag>> >>tag ;

: synchronous-reply? ( response synchronous -- ? )
    over reply? [ [ tag>> ] bi@ = ] [ 2drop f ] if ;

ERROR: cannot-send-synchronous-to-self message thread ;

M: cannot-send-synchronous-to-self summary
    drop "Cannot synchronous send to myself" ;

: send-synchronous ( message thread -- reply )
    dup self eq? [
        cannot-send-synchronous-to-self
    ] [
        [ <synchronous> dup ] dip send
        '[ _ synchronous-reply? ] (receive-if) data>>
    ] if ; 

: send-synchronous-timeout ( timeout message thread -- reply ) 
    dup self eq? [
        cannot-send-synchronous-to-self
    ] [
        [ <synchronous> 2dup ] dip send-timeout
        '[ _ synchronous-reply? ] (receive-if-timeout) data>>
    ] if ;   

: reply-synchronous ( message synchronous -- )
    dup expired?
    [ 2drop ] 
    [ [ <reply> ] keep sender>> send ] if ;

: handle-synchronous ( quot -- )
    (receive) [
        data>> swap call
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

\ registered-processes [ H{ } clone ] initialize
