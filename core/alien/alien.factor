! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math namespaces sequences system
kernel.private byte-arrays arrays init ;
IN: alien

! Some predicate classes used by the compiler for optimization
! purposes
PREDICATE: simple-alien < alien underlying>> not ;

UNION: simple-c-ptr
simple-alien POSTPONE: f byte-array ;

DEFER: pinned-c-ptr?

PREDICATE: pinned-alien < alien underlying>> pinned-c-ptr? ;

UNION: pinned-c-ptr
    pinned-alien POSTPONE: f ;

GENERIC: >c-ptr ( obj -- c-ptr )

M: c-ptr >c-ptr ; inline

SLOT: underlying

M: object >c-ptr underlying>> ; inline

GENERIC: expired? ( c-ptr -- ? ) flushable

M: alien expired? expired>> ;

M: f expired? drop t ;

: <alien> ( address -- alien )
    f <displaced-alien> { simple-c-ptr } declare ; inline

: <bad-alien> ( -- alien )
    -1 <alien> t >>expired ; inline

M: alien equal?
    over alien? [
        2dup [ expired? ] either? [
            [ expired? ] both?
        ] [
            [ alien-address ] bi@ =
        ] if
    ] [
        2drop f
    ] if ;

M: simple-alien hashcode* nip dup expired>> [ drop 1234 ] [ alien-address ] if ;

ERROR: alien-callback-error ;

: alien-callback ( return parameters abi quot -- alien )
    alien-callback-error ;

ERROR: alien-indirect-error ;

: alien-indirect ( ... funcptr return parameters abi -- )
    alien-indirect-error ;

ERROR: alien-invoke-error library symbol ;

: alien-invoke ( ... return library function parameters -- ... )
    2over alien-invoke-error ;

! Callbacks are registered in a global hashtable. Note that they
! are also pinned in a special callback area, so clearing this
! hashtable will not reclaim callbacks. It should only be
! cleared on startup.
SYMBOL: callbacks

[ H{ } clone callbacks set-global ] "alien" add-init-hook

<PRIVATE

TUPLE: expiry-check object alien ;

: recompute-value? ( check -- ? )
    dup [ alien>> expired? ] [ drop t ] if ;

PRIVATE>

: initialize-alien ( symbol quot -- )
    swap dup get-global dup recompute-value?
    [ drop [ call dup 31337 <alien> expiry-check boa ] dip set-global ]
    [ 2nip object>> ] if ; inline
