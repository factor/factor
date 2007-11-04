! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Remote Channels
USING: kernel init namespaces assocs arrays 
sequences channels match concurrency concurrency.distributed ;
IN: channels.remote

<PRIVATE

: remote-channels ( -- hash )
    \ remote-channels get-global ;
PRIVATE>

: publish ( channel -- id )
    random-64 dup >r remote-channels set-at r> ;

: get-channel ( id -- channel )
    remote-channels at ;

: unpublish ( id -- )
    remote-channels delete-at ;
    
<PRIVATE

MATCH-VARS: ?id ?value ;

SYMBOL: no-channel

: channel-process ( -- )
    receive
    {
        { { ?from ?tag { to ?id ?value  } }
          [ ?value ?id get-channel [ to f ] [ no-channel ] if* ?tag swap 2array ?from send ] }
        { { ?from ?tag { from ?id  } }
          [ ?id get-channel [ from ] [ no-channel ] if* ?tag swap 2array ?from send ] }
    } match-cond 
    channel-process ;

PRIVATE>

: start-channel-node ( -- )
    "remote-channels" get-process [ 
      [ channel-process ] spawn "remote-channels" swap register-process 
    ] unless ;

TUPLE: remote-channel node id ;

C: <remote-channel> remote-channel 

M: remote-channel to ( value remote-channel -- )
    dup >r [ \ to , remote-channel-id , , ] { } make r>
    remote-channel-node "remote-channels" <remote-process> 
    send-synchronous no-channel = [ no-channel throw ] when ;

M: remote-channel from ( remote-channel -- value )
    dup >r [ \ from , remote-channel-id , ] { } make r>
    remote-channel-node "remote-channels" <remote-process> 
    send-synchronous dup no-channel = [ no-channel throw ] when* ;

[
    H{ } clone \ remote-channels set-global
    start-channel-node
] "channel-registry" add-init-hook
