! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: generator errors generic hashtables kernel
kernel-internals math namespaces parser sequences strings words
;

! Some code for interfacing with C structures.

: define-getter ( offset type name -- )
    #! Define a word with stack effect ( alien -- obj ) in the
    #! current 'in' vocabulary.
    create-in >r c-getter swap add* r> swap define-compound ;

: define-setter ( offset type name -- )
    #! Define a word with stack effect ( obj alien -- ) in the
    #! current 'in' vocabulary.
    "set-" swap append create-in >r c-setter swap add* r>
    swap define-compound ;

: parse-c-decl ( string -- count name )
    "[]" split "" swap remove unclip
    >r
    dup empty? [ drop 1 ] [ [ string>number ] map product ] if
    r> over 1 > [ "[]" append ] when ;

: define-field ( offset type name -- offset )
    >r parse-c-decl [ c-type c-type-align ] keep
    >r swapd align r> r> 
    "struct-name" get swap "-" swap 3append
    3dup define-getter 3dup define-setter
    drop heap-size rot * + ;

: define-member ( max type -- max )
    heap-size max ;

TUPLE: struct-type ;

: if-value-structs? ( ctype true false -- )
    value-structs?
    [ drop call ] [ >r 2drop "void*" r> call ] if ; inline

M: struct-type unbox-parameter
    [ c-type-size %unbox-struct ]
    [ unbox-parameter ]
    if-value-structs? ;

M: struct-type unbox-return f swap c-type-size %unbox-struct ;

M: struct-type box-parameter
    [ c-type-size %box-struct ]
    [ box-parameter ]
    if-value-structs? ;

M: struct-type box-return f swap c-type-size %box-struct ;

M: struct-type stack-size
    [ c-type-size ] [ stack-size ] if-value-structs? ;

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
