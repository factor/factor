! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs destructors
kernel locals sequences serialize vectors
tokyo.alien.tcrdb tokyo.alien.tcutil tokyo.utils ;
IN: tokyo.remotedb

TUPLE: tokyo-remotedb handle disposed ;

INSTANCE: tokyo-remotedb assoc

: <tokyo-remotedb> ( host port -- tokyo-remotedb )
    [ tcrdbnew dup ] 2dip tcrdbopen drop
    tokyo-remotedb new [ (>>handle) ] keep ;

M: tokyo-remotedb dispose* [ tcrdbdel f ] change-handle drop ;

M:: tokyo-remotedb at* ( key db -- value/f ? )
    0 <int>          :> sizeout
    db handle>>      :> handle
    key object>bytes :> kbytes
    kbytes length    :> key-size
    handle kbytes key-size sizeout tcrdbget :> output
    output [
        [ memory>object ] [ tcfree ] bi t
    ] [ f f ] if* ;

M: tokyo-remotedb assoc-size ( db -- size ) handle>> tcrdbrnum ;

! FIXME: make this nicer
M:: tokyo-remotedb >alist ( db -- alist )
    db handle>>            :> handle
    0 <int>                :> size-out
    db assoc-size <vector> :> keys
    handle tcrdbiterinit drop
    [ handle size-out tcrdbiternext dup ] [
        [ memory>object ] [ tcfree ] bi
        keys push
    ] while drop
    keys [ dup db at 2array ] { } map-as ;

M:: tokyo-remotedb set-at ( value key db -- )
    db handle>>        :> handle
    key object>bytes   :> kbytes
    kbytes length      :> key-size
    value object>bytes :> vbytes
    vbytes length      :> value-size
    handle kbytes key-size vbytes value-size tcrdbput drop ;

M:: tokyo-remotedb delete-at ( key db -- )
    db handle>>      :> handle
    key object>bytes :> kbytes
    kbytes length    :> key-size
    handle kbytes key-size tcrdbout drop ;

M: tokyo-remotedb clear-assoc ( db -- ) handle>> tcrdbvanish drop ;

M: tokyo-remotedb equal? assoc= ;

M: tokyo-remotedb hashcode* assoc-hashcode ;
