! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler errors generic hashtables kernel lists
math namespaces parser strings words ;

! Some code for interfacing with C structures.

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

: bytes>cells cell / ceiling ;

: struct-constructor ( width -- )
    #! Make a word <foo> where foo is the structure name that
    #! allocates a Factor heap-local instance of this structure.
    #! Used for C functions that expect you to pass in a struct.
    "struct-name" get constructor-word
    swap bytes>cells [ <byte-array> ] cons
    define-compound ;

: array-constructor ( width -- )
    #! Make a word <foo-array> ( n -- byte-array ).
    "struct-name" get "-array" cat2 constructor-word
    swap bytes>cells [ * <byte-array> ] cons
    define-compound ;

: define-nth ( width -- )
    #! Make a word foo-nth ( n alien -- dsplaced-alien ).
    "struct-name" get "-nth" cat2 create-in
    swap [ swap >r * r> <displaced-alien> ] cons
    define-compound ;

: define-struct-type ( width -- )
    #! Define inline and pointer type for the struct. Pointer
    #! type is exactly like void*.
    dup struct-constructor
    dup array-constructor
    dup define-nth
    [
        "width" set
        cell "align" set
        [ swap <displaced-alien> ] "getter" set
    ] "struct-name" get define-c-type
    "void*" c-type "struct-name" get "*" cat2
    c-types get set-hash ;

: BEGIN-STRUCT: ( -- offset )
    scan "struct-name" set  0 ; parsing

: FIELD: ( offset -- offset )
    scan scan define-field ; parsing

: END-STRUCT ( length -- )
    define-struct-type ; parsing

: BEGIN-UNION: ( -- max )
    scan "struct-name" set  0 ; parsing

: MEMBER: ( max -- max )
    scan define-member ; parsing

: END-UNION ( max -- )
    define-struct-type ; parsing

BEGIN-STRUCT: int-box
    FIELD: int i
END-STRUCT

: box-int ( n -- box )
    <int-box> [ set-int-box-i ] keep ;
