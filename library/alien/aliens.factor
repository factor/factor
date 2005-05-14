! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: hashtables kernel lists math namespaces parser stdio ;

DEFER: dll?
BUILTIN: dll 15 dll? [ 1 "dll-path" f ] ;
DEFER: alien?
BUILTIN: alien 16 alien? ;
DEFER: byte-array?
BUILTIN: byte-array 19 byte-array? ;
DEFER: displaced-alien?
BUILTIN: displaced-alien 20 displaced-alien? ;

: NULL ( -- null )
    #! C null value.
    0 <alien> ;

: null? ( alien -- ? ) dup [ alien-address 0 = ] when ;

: null>f ( alien -- alien/f )
    dup alien-address 0 = [ drop f ] when ;

M: alien hashcode ( obj -- n )
    alien-address >fixnum ;

M: alien = ( obj obj -- ? )
    over alien? [
        alien-address swap alien-address =
    ] [
        2drop f
    ] ifte ;

: ALIEN: scan-word <alien> swons ; parsing

: DLL" skip-blank parse-string dlopen swons ; parsing

: library ( name -- object )
    dup [ "libraries" get hash ] when ;

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
        <namespace> [
          "abi" set
          "name" set
        ] extend swap set
    ] bind ;

: library-abi ( library -- abi )
    library [ [ "abi" get ] bind ] [ "cdecl" ] ifte* ;
