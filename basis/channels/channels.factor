! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
!
! Channels - based on ideas from newsqueak
USING: accessors kernel random sequences threads ;
IN: channels

TUPLE: channel receivers senders ;

: <channel> ( -- channel )
    V{ } clone V{ } clone channel boa ;

GENERIC: to ( value channel -- )
GENERIC: from ( channel -- value )

<PRIVATE

: wait ( channel -- )
    [ self ] dip senders>> push
    "channel send" suspend drop ;

: (to) ( value receivers -- )
    delete-random resume-with yield ;

: notify ( continuation channel -- channel )
    [ receivers>> push ] keep ;

: (from) ( senders -- )
    delete-random resume ;

PRIVATE>

M: channel to
    dup receivers>>
    [ dup wait to ] [ nip (to) ] if-empty ;

M: channel from
    [ self ] dip
    notify senders>>
    [ (from) ] unless-empty
    "channel receive" suspend ;
