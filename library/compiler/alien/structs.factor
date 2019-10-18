! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: assembler compiler errors generic
hashtables kernel kernel-internals math namespaces parser
sequences strings words ;

! Some code for interfacing with C structures.

: c-getter* ( name -- quot )
    c-getter [
        [ "Cannot read struct fields with type" throw ]
    ] unless* ;

: define-getter ( offset type name -- )
    #! Define a word with stack effect ( alien -- obj ) in the
    #! current 'in' vocabulary.
    create-in >r c-getter* swap add* r> swap define-compound ;

: c-setter* ( name -- quot )
    c-setter [
        [ "Cannot write struct fields with type" throw ]
    ] unless* ;

: define-setter ( offset type name -- )
    #! Define a word with stack effect ( obj alien -- ) in the
    #! current 'in' vocabulary.
    "set-" swap append create-in >r c-setter* swap add* r>
    swap define-compound ;

: parse-c-decl ( string -- count name )
    "[]" split "" swap remove unclip
    >r
    dup empty? [ drop 1 ] [ [ string>number ] map product ] if
    r> over 1 > [ "[]" append ] when ;

: define-field ( offset type name -- offset )
    >r parse-c-decl [ c-type c-type-align ] keep
    >r swapd align r> r> 
    "struct-name" get swap "-" swap append3
    3dup define-getter 3dup define-setter
    drop c-size rot * + ;

: define-member ( max type -- max )
    c-size max ;

TUPLE: struct-type ;

M: struct-type c-type-unbox c-type-size %unbox-struct ;

M: struct-type c-type-box c-type-size %box-struct ;

C: struct-type ( width -- type )
    <c-type> over set-delegate
    bootstrap-cell over set-c-type-align
    [ swap <displaced-alien> ] over set-c-type-getter
    [ set-c-type-size ] keep ;

: define-struct-type ( width -- )
    #! Define inline and pointer type for the struct. Pointer
    #! type is exactly like void*.
    <struct-type> "struct-name" get in get define-c-type ;

: c-struct? ( type -- ? ) c-types get hash struct-type? ;
