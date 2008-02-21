! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Remote Channels
USING: kernel init namespaces assocs arrays random
sequences channels match concurrency.messaging
concurrency.distributed threads ;
IN: channels.remote

<PRIVATE

: remote-channels ( -- hash )
    \ remote-channels get-global ;
PRIVATE>

: publish ( channel -- id )
    random-256 dup >r remote-channels set-at r> ;

: get-channel ( id -- channel )
    remote-channels at ;

: unpublish ( id -- )
    remote-channels delete-at ;
    
<PRIVATE

MATCH-VARS: ?from ?tag ?id ?value ;

SYMBOL: no-channel

: channel-process ( -- )
    receive [
        {
            { { to ?id ?value  }
            [ ?value ?id get-channel dup [ to f ] [ 2drop no-channel ] if ] }
            { { from ?id }
            [ ?id get-channel [ from ] [ no-channel ] if* ] }
        } match-cond
    ] keep reply-synchronous ;

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
    [ [ \ to , remote-channel-id , , ] { } make ] keep
    remote-channel-node "remote-channels" <remote-process> 
    send-synchronous no-channel = [ no-channel throw ] when ;

M: remote-channel from ( remote-channel -- value )
    [ [ \ from , remote-channel-id , ] { } make ] keep
    remote-channel-node "remote-channels" <remote-process> 
    send-synchronous dup no-channel = [ no-channel throw ] when* ;

[
    H{ } clone \ remote-channels set-global
    start-channel-node
] "channel-registry" add-init-hook
