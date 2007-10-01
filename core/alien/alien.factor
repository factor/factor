! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: assocs kernel math namespaces sequences system
byte-arrays bit-arrays float-arrays kernel.private tuples ;

! Some predicate classes used by the compiler for optimization
! purposes
PREDICATE: alien simple-alien
    underlying-alien not ;

UNION: simple-c-ptr
    simple-alien byte-array bit-array float-array POSTPONE: f ;

DEFER: pinned-c-ptr?

PREDICATE: alien pinned-alien
    underlying-alien pinned-c-ptr? ;

UNION: pinned-c-ptr
    alien POSTPONE: f ;

UNION: c-ptr
    alien bit-array byte-array float-array POSTPONE: f ;

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

global [
    libraries [ H{ } assoc-like ] change
] bind

TUPLE: library path abi dll ;

: library ( name -- library ) libraries get at ;

: <library> ( path abi -- library ) f \ library construct-boa ;

: load-library ( name -- dll )
    library dup [
        dup library-dll [ ] [
            dup library-path dup [
                dlopen dup rot set-library-dll
            ] [
                2drop f
            ] if
        ] ?if
    ] when ;

: add-library ( name path abi -- )
    <library> swap libraries get set-at ;

TUPLE: alien-callback return parameters abi quot xt ;

TUPLE: alien-callback-error ;

: alien-callback ( return parameters abi quot -- alien )
    \ alien-callback-error construct-empty throw ;

TUPLE: alien-indirect return parameters abi ;

TUPLE: alien-indirect-error ;

: alien-indirect ( ... funcptr return parameters abi -- )
    \ alien-indirect-error construct-empty throw ;

TUPLE: alien-invoke library function return parameters ;

TUPLE: alien-invoke-error library symbol ;

: alien-invoke ( ... return library function parameters -- ... )
    pick pick \ alien-invoke-error construct-boa throw ;
