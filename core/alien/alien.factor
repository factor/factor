! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors continuations.private
init kernel kernel.private math namespaces sequences ;
IN: alien

BUILTIN: alien { underlying c-ptr read-only initial: f } expired ;
BUILTIN: dll { path byte-array read-only initial: B{ } } ;

PREDICATE: pinned-alien < alien underlying>> not ;

UNION: pinned-c-ptr pinned-alien POSTPONE: f ;

GENERIC: element-size ( seq -- n ) flushable

M: byte-array element-size drop 1 ; inline

M: byte-vector element-size drop 1 ; inline

M: slice element-size seq>> element-size ; inline

M: f element-size drop 1 ; inline

GENERIC: byte-length ( obj -- n ) flushable

M: object byte-length [ length ] [ element-size ] bi * ; inline

GENERIC: >c-ptr ( obj -- c-ptr ) flushable

M: c-ptr >c-ptr ; inline

M: slice >c-ptr
    [ [ from>> ] [ element-size ] bi * ] [ seq>> >c-ptr ] bi
    <displaced-alien> ; inline

SLOT: underlying

M: object >c-ptr underlying>> ; inline

: binary-object ( obj -- c-ptr n )
    [ >c-ptr ] [ byte-length ] bi ; inline

GENERIC: expired? ( c-ptr -- ? ) flushable

M: alien expired? expired>> ;

M: f expired? drop t ;

: <alien> ( address -- alien )
    f <displaced-alien> { pinned-c-ptr } declare ; inline

: <bad-alien> ( -- alien )
    -1 <alien> t >>expired ; inline

M: alien equal?
    over alien? [
        2dup [ expired? ] either? [
            [ expired? ] both?
        ] [
            [ alien-address ] same?
        ] if
    ] [
        2drop f
    ] if ;

M: pinned-alien hashcode*
    nip dup expired>> [ drop 1234 ] [ alien-address ] if ;

SINGLETONS: stdcall thiscall fastcall cdecl mingw ;

UNION: abi stdcall thiscall fastcall cdecl mingw ;

: callee-cleanup? ( abi -- ? )
    { stdcall fastcall thiscall } member? ;

ERROR: alien-callback-error ;

: alien-callback ( return parameters abi quot -- alien )
    alien-callback-error ;

ERROR: alien-indirect-error ;

: alien-indirect ( args... funcptr return parameters abi -- return... )
    alien-indirect-error ;

ERROR: alien-invoke-error library symbol ;

: alien-invoke ( args... return library function parameters -- return... )
    2over alien-invoke-error ;

ERROR: alien-assembly-error code ;

: alien-assembly ( args... return parameters abi quot -- return... )
    dup alien-assembly-error ;

<PRIVATE

! Callbacks are registered in a global hashtable. Note that they
! are also pinned in a special callback area, so clearing this
! hashtable will not reclaim callbacks. It should only be
! cleared on startup.
SYMBOL: callbacks

[ H{ } clone callbacks set-global ] "alien" add-startup-hook

! Used by compiler.codegen to wrap callback bodies
: do-callback ( callback-quot wait-quot: ( callback -- ) -- )
    t CONTEXT-OBJ-IN-CALLBACK-P set-context-object
    init-namespaces
    init-catchstack
    current-callback
    [ 2drop call ] [ swap call( callback -- ) drop ] 3bi ; inline

! A utility for defining global variables that are recompiled in
! every session
TUPLE: expiry-check object alien ;

: recompute-value? ( check -- ? )
    dup [ alien>> expired? ] [ drop t ] if ;

PRIVATE>

: initialize-alien ( symbol quot -- )
    swap dup get-global dup recompute-value?
    [ drop [ call dup 31337 <alien> expiry-check boa ] dip set-global ]
    [ 2nip object>> ] if ; inline
