! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: byte-arrays hashtables io kernel math namespaces parser
sequences ;

: <alien> ( address -- alien ) f <displaced-alien> ; inline

: alien>native-string ( alien -- string )
    os { "windows" "wince" } member?
    [ alien>u16-string ] [ alien>char-string ] if ;

: dll-path ( dll -- string )
    (dll-path) alien>native-string ;

UNION: c-ptr byte-array alien POSTPONE: f ;

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

global [ "libraries" nest drop ] bind

: library ( name -- library ) "libraries" get hash ;

: load-library ( name -- dll )
    library dup [
        [
            "dll" get dup [
                drop "name" get dlopen dup "dll" set
            ] unless
        ] bind
    ] when ;

: add-library ( name path abi -- )
    "libraries" get [
        [ "abi" set "name" set ] make-hash swap set
    ] bind ;

: library-abi ( library -- abi )
    library "abi" swap ?hash [ "cdecl" ] unless* ;
