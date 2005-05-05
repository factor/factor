! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler errors generic hashtables kernel lists math
namespaces parser sequences strings words ;

: <c-type> ( -- type )
    <namespace> [
        [ "No setter" throw ] "setter" set
        [ "No getter" throw ] "getter" set
        "no boxer" "boxer" set
        #box "box-op" set
        "no unboxer" "unboxer" set
        #unbox "unbox-op" set
        0 "width" set
    ] extend ;

SYMBOL: c-types

: c-type ( name -- type )
    dup c-types get hash [ ] [
        "No such C type: " swap cat2 throw f
    ] ?ifte ;

: c-size ( name -- size )
    c-type [ "width" get ] bind ;

: define-deref ( hash name vocab -- )
    >r "*" swap append r> create
    "getter" rot hash 0 swons define-compound ;

: define-c-type ( quot name vocab -- )
    >r >r <c-type> swap extend r> 2dup r> define-deref
    c-types get set-hash ; inline

: <c-object> ( type -- byte-array )
    c-size cell / ceiling <byte-array> ;

: <c-array> ( n type -- byte-array )
    c-size * cell / ceiling <byte-array> ;

: define-out ( name -- )
    #! Out parameter constructor for integral types.
    dup "alien" constructor-word
    swap c-type [
        [
            "width" get , \ <c-object> , 0 , "setter" get %
        ] make-list
    ] bind define-compound ;

: define-primitive-type ( quot name -- )
    [ "alien" define-c-type ] keep define-out ;

global [ c-types nest drop ] bind

[
    [ alien-unsigned-cell <alien> ] "getter" set
    [
        >r >r alien-address r> r> set-alien-unsigned-cell
    ] "setter" set
    cell "width" set
    cell "align" set
    "box_alien" "boxer" set
    "unbox_alien" "unboxer" set
] "void*" define-primitive-type

[
    [ alien-signed-8 ] "getter" set
    [ set-alien-signed-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_signed_8" "boxer" set
    "unbox_signed_8" "unboxer" set
] "longlong" define-primitive-type

[
    [ alien-unsigned-8 ] "getter" set
    [ set-alien-unsigned-8 ] "setter" set
    8 "width" set
    8 "align" set
    "box_unsinged_8" "boxer" set
    "unbox_unsigned_8" "unboxer" set
] "ulonglong" define-primitive-type

[
    [ alien-signed-4 ] "getter" set
    [ set-alien-signed-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_signed_4" "boxer" set
    "unbox_signed_4" "unboxer" set
] "int" define-primitive-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    4 "width" set
    4 "align" set
    "box_unsigned_4" "boxer" set
    "unbox_unsigned_4" "unboxer" set
] "uint" define-primitive-type

[
    [ alien-signed-2 ] "getter" set
    [ set-alien-signed-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_signed_2" "boxer" set
    "unbox_signed_2" "unboxer" set
] "short" define-primitive-type

[
    [ alien-unsigned-2 ] "getter" set
    [ set-alien-unsigned-2 ] "setter" set
    2 "width" set
    2 "align" set
    "box_unsigned_2" "boxer" set
    "unbox_unsigned_2" "unboxer" set
] "ushort" define-primitive-type

[
    [ alien-signed-1 ] "getter" set
    [ set-alien-signed-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_signed_1" "boxer" set
    "unbox_signed_1" "unboxer" set
] "char" define-primitive-type

[
    [ alien-unsigned-1 ] "getter" set
    [ set-alien-unsigned-1 ] "setter" set
    1 "width" set
    1 "align" set
    "box_unsigned_1" "boxer" set
    "unbox_unsigned_1" "unboxer" set
] "uchar" define-primitive-type

[
    [ alien-c-string ] "getter" set
    [ set-alien-c-string ] "setter" set
    cell "width" set
    cell "align" set
    "box_c_string" "boxer" set
    "unbox_c_string" "unboxer" set
] "char*" define-primitive-type

[
    [ alien-unsigned-4 ] "getter" set
    [ set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_utf16_string" "boxer" set
    "unbox_utf16_string" "unboxer" set
] "ushort*" define-primitive-type

[
    [ alien-unsigned-4 0 = not ] "getter" set
    [ 1 0 ? set-alien-unsigned-4 ] "setter" set
    cell "width" set
    cell "align" set
    "box_boolean" "boxer" set
    "unbox_boolean" "unboxer" set
] "bool" define-primitive-type

[
    [ alien-float ] "getter" set
    [ set-alien-float ] "setter" set
    cell "width" set
    cell "align" set
    "box_float" "boxer" set
    #box-float "box-op" set
    "unbox_float" "unboxer" set
    #unbox-float "unbox-op" set
] "float" define-primitive-type

[
    [ alien-double ] "getter" set
    [ set-alien-double ] "setter" set
    cell 2 * "width" set
    cell 2 * "align" set
    "box_double" "boxer" set
    #box-double "box-op" set
    "unbox_double" "unboxer" set
    #unbox-double "unbox-op" set
] "double" define-primitive-type

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
