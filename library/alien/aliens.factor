! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: hashtables kernel lists math namespaces parser stdio ;

DEFER: dll?
BUILTIN: dll 15 dll? [ 1 "dll-path" f ] ;

DEFER: alien?
BUILTIN: alien 16 alien? ;

DEFER: displaced-alien?
BUILTIN: displaced-alien 20 displaced-alien? ;

: NULL ( -- null )
    #! C null value.
    0 <alien> ;

: null? ( alien -- ? ) dup alien? [ alien-address 0 = ] when ;

M: alien hashcode ( obj -- n )
    alien-address >fixnum ;

M: alien = ( obj obj -- ? )
    over alien? [
        alien-address swap alien-address =
    ] [
        2drop f
    ] ifte ;

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

! This will go elsewhere soon
: byte-bit ( n alien -- byte bit )
    over -3 shift alien-unsigned-1 swap 7 bitand ;

: bit-nth ( n alien -- ? )
    byte-bit 1 swap shift bitand 0 > ;

: set-bit ( ? byte bit -- byte )
    1 swap shift rot [ bitor ] [ bitnot bitand ] ifte ;

: set-bit-nth ( ? n alien -- )
    [ byte-bit set-bit ] 2keep
    swap -3 shift set-alien-unsigned-1 ;

: ALIEN: scan-word <alien> swons ; parsing
