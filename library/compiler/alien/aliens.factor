! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays hashtables io kernel lists math namespaces parser
sequences ;

: <alien> ( address -- alien ) f <displaced-alien> ; inline

UNION: c-ptr byte-array alien ;

M: alien = ( obj obj -- ? )
    over alien? [
        2dup [ expired? ] 2apply 2dup or [
            2swap 2drop
        ] [
            2drop [ alien-address ] 2apply
        ] if =
    ] [
        2drop f
    ] if ;

global [ "libraries" nest drop ] bind

: library ( name -- object ) "libraries" get hash ;

: load-library ( name -- dll )
    library dup [
        [
            "dll" get dup [
                drop "name" get dlopen dup "dll" set
            ] unless
        ] bind
    ] when ;

: add-library ( library name abi -- )
    "libraries" get [
        [ "abi" set "name" set ] make-hash swap set
    ] bind ;

: add-simple-library ( name file -- ) 
    windows? ".dll" ".so" ? append
    windows? "stdcall" "cdecl" ? add-library ;

: library-abi ( library -- abi )
    library "abi" swap ?hash [ "cdecl" ] unless* ;
