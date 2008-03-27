! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math namespaces sequences system
kernel.private tuples bit-arrays byte-arrays float-arrays 
arrays ;
IN: alien

! Some predicate classes used by the compiler for optimization
! purposes
PREDICATE: simple-alien < alien
    underlying-alien not ;

UNION: simple-c-ptr
simple-alien POSTPONE: f byte-array bit-array float-array ;

UNION: c-ptr
alien POSTPONE: f byte-array bit-array float-array ;

DEFER: pinned-c-ptr?

PREDICATE: pinned-alien < alien
    underlying-alien pinned-c-ptr? ;

UNION: pinned-c-ptr
    pinned-alien POSTPONE: f ;

M: f expired? drop t ;

: <alien> ( address -- alien )
    f <displaced-alien> { simple-c-ptr } declare ; inline

: alien>native-string ( alien -- string )
    windows? [ alien>u16-string ] [ alien>char-string ] if ;

: dll-path ( dll -- string )
    (dll-path) alien>native-string ;

M: alien equal?
    over alien? [
        2dup [ expired? ] either? [
            [ expired? ] both?
        ] [
            [ alien-address ] 2apply =
        ] if
    ] [
        2drop f
    ] if ;

SYMBOL: libraries

libraries global [ H{ } assoc-like ] change-at

TUPLE: library path abi dll ;

: library ( name -- library ) libraries get at ;

: <library> ( path abi -- library )
    over dup [ dlopen ] when \ library construct-boa ;

: load-library ( name -- dll )
    library dup [ library-dll ] when ;

: add-library ( name path abi -- )
    <library> swap libraries get set-at ;

TUPLE: alien-callback return parameters abi quot xt ;

ERROR: alien-callback-error ;

: alien-callback ( return parameters abi quot -- alien )
    alien-callback-error ;

TUPLE: alien-indirect return parameters abi ;

ERROR: alien-indirect-error ;

: alien-indirect ( ... funcptr return parameters abi -- )
    alien-indirect-error ;

TUPLE: alien-invoke library function return parameters abi ;

ERROR: alien-invoke-error library symbol ;

: alien-invoke ( ... return library function parameters -- ... )
    2over alien-invoke-error ;
