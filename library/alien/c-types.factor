! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler compiler-backend errors generic
hashtables kernel kernel-internals lists math namespaces parser
sequences strings words ;

: <c-type> ( -- type )
    <namespace> [
        [ "No setter" throw ] "setter" set
        [ "No getter" throw ] "getter" set
        "no boxer" "boxer" set
        "no unboxer" "unboxer" set
        << int-regs f >> "reg-class" set
        0 "width" set
    ] extend ;

SYMBOL: c-types

: c-type ( name -- type )
    dup c-types get hash [ ] [
        "No such C type: " swap append throw f
    ] ?ifte ;

: c-size ( name -- size )
    c-type [ "width" get ] bind ;

: define-c-type ( quot name -- )
    >r <c-type> swap extend r> c-types get set-hash ;

: <c-object> ( size -- c-ptr ) cell / ceiling <byte-array> ;

: <c-array> ( n size -- c-ptr ) * <c-object> ;

: define-pointer ( type -- )
    "void*" c-type swap "*" append c-types get set-hash ;

: define-deref ( name vocab -- )
    >r dup "*" swap append r> create
    "getter" rot c-type hash 0 swons define-compound ;

: c-constructor ( name vocab -- )
    #! Make a word <foo> where foo is the structure name that
    #! allocates a Factor heap-local instance of this structure.
    #! Used for C functions that expect you to pass in a struct.
    dupd constructor-word
    swap c-size [ <c-object> ] cons
    define-compound ;

: array-constructor ( name vocab -- )
    #! Make a word <foo-array> ( n -- byte-array ).
    >r dup "-array" append r> constructor-word
    swap c-size [ <c-array> ] cons
    define-compound ;

: define-nth ( name vocab -- )
    #! Make a word foo-nth ( n alien -- dsplaced-alien ).
    >r dup "-nth" append r> create
    swap dup c-size [ rot * ] cons "getter" rot c-type hash
    append define-compound ;

: define-set-nth ( name vocab -- )
    #! Make a word foo-nth ( n alien -- dsplaced-alien ).
    >r "set-" over "-nth" append3 r> create
    swap dup c-size [ rot * ] cons "setter" rot c-type hash
    append define-compound ;

: define-out ( name vocab -- )
    #! Out parameter constructor for integral types.
    dupd constructor-word
    swap c-type [
        [
            "width" get , \ <c-object> , \ tuck , 0 ,
            "setter" get %
        ] make-list
    ] bind define-compound ;

: init-c-type ( name vocab -- )
    over define-pointer
    2dup c-constructor
    2dup array-constructor
    define-nth ;

: define-primitive-type ( quot name -- )
    [ define-c-type ] keep "alien"
    2dup init-c-type
    2dup define-deref
    2dup define-set-nth
    define-out ;

: (typedef) c-types get [ >r get r> set ] bind ;

: typedef ( old new -- )
    over "*" append over "*" append (typedef) (typedef) ;

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
    "unbox_float" "unboxer" set
    << float-regs f 4 >> "reg-class" set
] "float" define-primitive-type

[
    [ alien-double ] "getter" set
    [ set-alien-double ] "setter" set
    cell 2 * "width" set
    cell 2 * "align" set
    "box_double" "boxer" set
    "unbox_double" "unboxer" set
    << float-regs f 8 >> "reg-class" set
] "double" define-primitive-type

! FIXME for 64-bit platforms
"int" "long" typedef
"uint" "ulong" typedef
