! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs destructors fry functors
kernel locals sequences serialize tokyo.alien.tcutil tokyo.utils vectors ;
IN: tokyo.assoc-functor

FUNCTOR: define-tokyo-assoc-api ( T N -- )

DBGET      IS ${T}get
DBPUT      IS ${T}put
DBOUT      IS ${T}out
DBDEL      IS ${T}del
DBRNUM     IS ${T}rnum
DBITERINIT IS ${T}iterinit
DBITERNEXT IS ${T}iternext
DBVANISH   IS ${T}vanish

DBKEYS DEFINES tokyo-${N}-keys

TYPE DEFINES-CLASS tokyo-${N}

WHERE

TUPLE: TYPE handle disposed ;

INSTANCE: TYPE assoc

M: TYPE dispose* [ DBDEL f ] change-handle drop ;

M: TYPE at* ( key db -- value/f ? )
    handle>> swap object>bytes dup length 0 <int>
    DBGET [ [ memory>object ] [ tcfree ] bi t ] [ f f ] if* ;

M: TYPE assoc-size ( db -- size ) handle>> DBRNUM ;

: DBKEYS ( db -- keys )
    [ assoc-size <vector> ] [ handle>> ] bi
    dup DBITERINIT drop 0 <int>
    [ 2dup DBITERNEXT dup ] [
        [ memory>object ] [ tcfree ] bi
        [ pick ] dip swap push
    ] while 3drop ;

M: TYPE >alist ( db -- alist )
    [ DBKEYS dup ] keep '[ dup _ at 2array ] map! drop ;

M: TYPE set-at ( value key db -- )
    handle>> swap rot [ object>bytes dup length ] bi@ DBPUT drop ;

M: TYPE delete-at ( key db -- )
    handle>> swap object>bytes dup length DBOUT drop ;

M: TYPE clear-assoc ( db -- ) handle>> DBVANISH drop ;

M: TYPE equal? assoc= ;

M: TYPE hashcode* assoc-hashcode ;

;FUNCTOR
