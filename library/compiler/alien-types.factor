! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler errors hashtables kernel lists math
namespaces parser strings words ;

! Some code for interfacing with C structures.

: BEGIN-ENUM:
    #! C-style enumerations. Their use is not encouraged unless
    #! it is for C library interfaces. Used like this:
    #!
    #! BEGIN-ENUM 0
    #!     ENUM: x
    #!     ENUM: y
    #!     ENUM: z
    #! END-ENUM
    #!
    #! This is the same as : x 0 ; : y 1 ; : z 2 ;.
    scan str>number ; parsing

: ENUM:
    dup CREATE swap unit define-compound 1 + ; parsing

: END-ENUM
    drop ; parsing

: <c-type> ( -- type )
    <namespace> [
        [ "No setter" throw ] "setter" set
        [ "No getter" throw ] "getter" set
        "no boxer" "boxer" set
        "no unboxer" "unboxer" set
        0 "width" set
    ] extend ;

SYMBOL: c-types

: c-type ( name -- type )
    dup c-types get hash [ ] [
        "No such C type: " swap cat2 throw f
    ] ?ifte ;

: size ( name -- size )
    c-type [ "width" get ] bind ;

: define-c-type ( quot name -- )
    c-types get [ >r <c-type> swap extend r> set ] bind ; inline

: define-getter ( offset type name -- )
    #! Define a word with stack effect ( alien -- obj ) in the
    #! current 'in' vocabulary.
    create-in >r
    [ "getter" get ] bind cons r> swap define-compound ;

: define-setter ( offset type name -- )
    #! Define a word with stack effect ( obj alien -- ) in the
    #! current 'in' vocabulary.
    "set-" swap cat2 create-in >r
    [ "setter" get ] bind cons r> swap define-compound ;

: define-field ( offset type name -- offset )
    >r c-type dup >r [ "align" get ] bind align r> r>
    "struct-name" get swap "-" swap cat3
    ( offset type name -- )
    3dup define-getter 3dup define-setter
    drop [ "width" get ] bind + ;

: define-member ( max type -- max )
    c-type [ "width" get ] bind max ;

: define-constructor ( width -- )
    #! Make a word <foo> where foo is the structure name that
    #! allocates a Factor heap-local instance of this structure.
    #! Used for C functions that expect you to pass in a struct.
    [ <local-alien> ] cons
    [ "<" , "struct-name" get , ">" , ] make-string
    create-in swap
    define-compound ;

: define-struct-type ( width -- )
    #! Define inline and pointer type for the struct. Pointer
    #! type is exactly like void*.
    [ "width" set ] "struct-name" get define-c-type
    "void*" c-type "struct-name" get "*" cat2
    c-types get set-hash ;

: BEGIN-STRUCT: ( -- offset )
    scan "struct-name" set  0 ; parsing

: FIELD: ( offset -- offset )
    scan scan define-field ; parsing

: END-STRUCT ( length -- )
    dup define-constructor define-struct-type ; parsing

: BEGIN-UNION: ( -- max )
    scan "struct-name" set  0 ; parsing

: MEMBER: ( max -- max )
    scan define-member ; parsing

: END-UNION ( max -- )
    dup define-constructor define-struct-type ; parsing

: NULL ( -- null )
    #! C null value.
    0 <alien> ;

global [ <namespace> c-types set ] bind

[
    [ alien-unsigned-cell <alien> ] "getter" set
    [ alien-address set-alien-unsigned-cell ] "setter" set
    cell "width" set
    cell "align" set
    "box_alien" "boxer" set
    "unbox_alien" "unboxer" set
] "void*" define-c-type

[
    [ alien-signed-8 ] "getter" set
    [ set-alien-signed-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_signed_8" "boxer" set
    "unbox_signed_8" "unboxer" set
] "longlong" define-c-type

[
    [ alien-unsigned-8 ] "getter" set
    [ set-alien-unsigned-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_unsinged_8" "boxer" set
    "unbox_unsigned_8" "unboxer" set
] "ulonglong" define-c-type

[
    [ alien-signed-4 ] "getter" set
    [ set-alien-signed-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_signed_4" "boxer" set
    "unbox_signed_4" "unboxer" set
] "int" define-c-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_unsigned_4" "boxer" set
    "unbox_unsigned_4" "unboxer" set
] "uint" define-c-type

[
    [ alien-signed-2 ] "getter" set
    [ set-alien-signed-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_signed_2" "boxer" set
    "unbox_signed_2" "unboxer" set
] "short" define-c-type

[
    [ alien-unsigned-2 ] "getter" set
    [ set-alien-unsigned-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_unsigned_2" "boxer" set
    "unbox_unsigned_2" "unboxer" set
] "ushort" define-c-type

[
    [ alien-signed-1 ] "getter" set
    [ set-alien-signed-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_signed_1" "boxer" set
    "unbox_signed_1" "unboxer" set
] "char" define-c-type

[
    [ alien-unsigned-1 ] "getter" set
    [ set-alien-unsigned-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_unsigned_1" "boxer" set
    "unbox_unsigned_1" "unboxer" set
] "uchar" define-c-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_c_string" "boxer" set
    "unbox_c_string" "unboxer" set
] "char*" define-c-type

! This is not the best way to do it.
[
    [ alien-value-string ] "getter" set
    256 "width" set
    cell "align" set
] "uchar256" define-c-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_utf16_string" "boxer" set
    "unbox_utf16_string" "unboxer" set
] "ushort*" define-c-type

[
    [ alien-unsigned-4 0 = not ] "getter" set
    [ 1 0 ? set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_boolean" "boxer" set
    "unbox_boolean" "unboxer" set
] "bool" define-c-type

: alias-c-type ( old new -- )
    c-types get [ >r get r> set ] bind ;

! FIXME for 64-bit platforms
"int" "long" alias-c-type
"uint" "ulong" alias-c-type

: ALIAS:
    #! Followed by old then new. This is a parsing word so that
    #! we can define aliased types, and then a C struct, in the
    #! same source file.
    scan scan alias-c-type ; parsing
