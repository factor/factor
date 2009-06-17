! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs destructors kernel libc locals
sequences serialize tokyo.alien.tcadb tokyo.alien.tcutil vectors ;
IN: tokyo.cabinet.abstract

TUPLE: tokyo-abstractdb handle disposed ;

INSTANCE: tokyo-abstractdb assoc

: <tokyo-abstractdb> ( name -- tokyo-abstractdb )
    tcadbnew [ swap tcadbopen drop ] keep
    tokyo-abstractdb new [ (>>handle) ] keep ;

M: tokyo-abstractdb dispose* [ tcadbdel f ] change-handle drop ;

M:: tokyo-abstractdb at* ( key db -- value/f ? )
    0 <int>          :> sizeout
    db handle>>      :> handle
    key object>bytes :> kbytes
    kbytes length    :> key-size
    handle kbytes key-size sizeout tcadbget :> output
    output [
        [ sizeout *int memory>byte-array ] [ tcfree ] bi bytes>object t
    ] [ f f ] if* ;

M: tokyo-abstractdb assoc-size ( db -- size ) handle>> tcadbrnum ;

! FIXME: make this nicer
M:: tokyo-abstractdb >alist ( db -- alist )
    db handle>>            :> handle
    0 <int>                :> size-out
    db assoc-size <vector> :> keys
    handle tcadbiterinit drop
    [ handle size-out tcadbiternext dup ] [
        [ size-out *int memory>byte-array ] [ tcfree ] bi
        bytes>object keys push
    ] while drop
    keys [ dup db at 2array ] { } map-as ;

M:: tokyo-abstractdb set-at ( value key db -- )
    db handle>>        :> handle
    key object>bytes   :> kbytes
    kbytes length      :> key-size
    value object>bytes :> vbytes
    vbytes length      :> value-size
    handle kbytes key-size vbytes value-size tcadbput drop ;

M:: tokyo-abstractdb delete-at ( key db -- )
    db handle>>      :> handle
    key object>bytes :> kbytes
    kbytes length    :> key-size
    handle kbytes key-size tcadbout drop ;

M: tokyo-abstractdb clear-assoc ( db -- ) handle>> tcadbvanish drop ;

M: tokyo-abstractdb equal? assoc= ;

M: tokyo-abstractdb hashcode* assoc-hashcode ;
