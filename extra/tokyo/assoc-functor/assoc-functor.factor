! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs
destructors functors kernel sequences serialize
tokyo.alien.tcutil tokyo.utils vectors ;
IN: tokyo.assoc-functor

<FUNCTOR: define-tokyo-assoc-api ( T N -- )

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

M: TYPE at*
    handle>> swap object>bytes dup length 0 int <ref>
    DBGET [ [ memory>object ] [ tcfree ] bi t ] [ f f ] if* ;

M: TYPE assoc-size handle>> DBRNUM ;

: DBKEYS ( db -- keys )
    [ assoc-size <vector> ] [ handle>> ] bi
    dup DBITERINIT drop 0 int <ref>
    [ 2dup DBITERNEXT ] [
        [ memory>object ] [ tcfree ] bi
        reach push
    ] while* 2drop ;

M: TYPE >alist
    [ DBKEYS dup ] keep '[ dup _ at 2array ] map! drop ;

M: TYPE set-at
    handle>> spin [ object>bytes dup length ] bi@ DBPUT drop ;

M: TYPE delete-at
    handle>> swap object>bytes dup length DBOUT drop ;

M: TYPE clear-assoc handle>> DBVANISH drop ;

M: TYPE equal? assoc= ;

M: TYPE hashcode* assoc-hashcode ;

;FUNCTOR>
