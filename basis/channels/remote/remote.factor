! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Remote Channels
USING: kernel init namespaces assocs arrays random
sequences channels match concurrency.messaging
concurrency.distributed threads accessors ;
IN: channels.remote

<PRIVATE

: remote-channels ( -- hash )
    \ remote-channels get-global ;
PRIVATE>

: publish ( channel -- id )
    256 random-bits dup [ remote-channels set-at ] dip ;

: get-channel ( id -- channel )
    remote-channels at ;

: unpublish ( id -- )
    remote-channels delete-at ;
    
<PRIVATE

MATCH-VARS: ?from ?tag ?id ?value ;

SYMBOL: no-channel
TUPLE: to-message id value ;
TUPLE: from-message id ;

: channel-thread ( -- )
    [
        {
            { T{ to-message f ?id ?value  }
            [ ?value ?id get-channel dup [ to f ] [ 2drop no-channel ] if ] }
            { T{ from-message f ?id }
            [ ?id get-channel [ from ] [ no-channel ] if* ] }
        } match-cond
    ] handle-synchronous ;

: start-channel-node ( -- )
    "remote-channels" get-remote-thread [
        [ channel-thread t ] "Remote channels" spawn-server
        "remote-channels" register-remote-thread 
    ] unless ;

PRIVATE>

TUPLE: remote-channel node id ;

C: <remote-channel> remote-channel 

<PRIVATE

: send-message ( message remote-channel -- value )
    node>> "remote-channels" <remote-thread> 
    send-synchronous dup no-channel = [ no-channel throw ] when* ;
    
PRIVATE>

M: remote-channel to ( value remote-channel -- )
    [ id>> swap to-message boa ] keep send-message drop ;

M: remote-channel from ( remote-channel -- value )
    [ id>> from-message boa ] keep send-message ;

[
    H{ } clone \ remote-channels set-global
    start-channel-node
] "channel-registry" add-init-hook
