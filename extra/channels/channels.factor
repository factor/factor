! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Channels - based on ideas from newsqueak
USING: kernel sequences sequences.lib threads continuations random math ;
IN: channels

TUPLE: channel receivers senders ;

: <channel> ( -- channel )
    V{ } clone V{ } clone channel construct-boa ;

GENERIC: to ( value channel -- )
GENERIC: from ( channel -- value )

<PRIVATE

: wait ( channel -- )
    [ channel-senders push stop ] curry callcc0 ;

: (to) ( value receivers -- )
    delete-random schedule-thread-with yield ;

: notify ( continuation channel -- channel )
    [ channel-receivers push ] keep ;

: (from) ( senders -- * )
    delete-random continue ;

PRIVATE>

M: channel to ( value channel -- )
    dup channel-receivers
    dup empty? [ drop dup wait to ] [ nip (to) ] if ;

M: channel from ( channel -- value )
    [
        notify channel-senders
        dup empty? [ stop ] [ (from) ] if
    ] curry callcc1 ;
