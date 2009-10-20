! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Remote Channels
USING: kernel init namespaces make assocs arrays random
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

: channel-process ( -- )
    [
        {
            { { to ?id ?value  }
            [ ?value ?id get-channel dup [ to f ] [ 2drop no-channel ] if ] }
            { { from ?id }
            [ ?id get-channel [ from ] [ no-channel ] if* ] }
        } match-cond
    ] handle-synchronous ;

PRIVATE>

: start-channel-node ( -- )
    "remote-channels" get-process [
        "remote-channels" 
        [ channel-process t ] "Remote channels" spawn-server
        register-process 
    ] unless ;

TUPLE: remote-channel node id ;

C: <remote-channel> remote-channel 

M: remote-channel to ( value remote-channel -- )
    [ [ \ to , id>> , , ] { } make ] keep
    node>> "remote-channels" <remote-process> 
    send-synchronous no-channel = [ no-channel throw ] when ;

M: remote-channel from ( remote-channel -- value )
    [ [ \ from , id>> , ] { } make ] keep
    node>> "remote-channels" <remote-process> 
    send-synchronous dup no-channel = [ no-channel throw ] when* ;

[
    H{ } clone \ remote-channels set-global
    start-channel-node
] "channel-registry" add-startup-hook
