! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: arrays hashtables io kernel lists math namespaces parser ;

UNION: c-ptr byte-array alien displaced-alien ;

M: alien hashcode ( obj -- n )
    alien-address >fixnum ;

M: alien = ( obj obj -- ? )
    over alien? [
        alien-address swap alien-address =
    ] [
        2drop f
    ] if ;

: library ( name -- object ) "libraries" get hash ;

: load-library ( name -- dll )
    #! Higher level wrapper around dlopen primitive.
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

: library-abi ( library -- abi )
    library "abi" swap ?hash [ "cdecl" ] unless* ;

: DLL" skip-blank parse-string dlopen swons ; parsing

: ALIEN: scan-word <alien> swons ; parsing
