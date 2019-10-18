! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
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
    "[]" split "" swap remove unclip >r dup empty?
    [ drop 1 ] [ [ string>number ] map product ] if r> over 1 > [ "[]" append ] when ;

: define-field ( offset type name -- offset )
    >r parse-c-decl [ c-align ] keep
    >r swapd align r> r> 
    "struct-name" get swap "-" swap append3
    3dup define-getter 3dup define-setter
    drop c-size rot * + ;

: define-member ( max type -- max )
    c-size max ;

: define-struct-type ( width -- )
    #! Define inline and pointer type for the struct. Pointer
    #! type is exactly like void*.
    [
        "width" set
        bootstrap-cell "align" set
        [ swap <displaced-alien> ] "getter" set
        "width" get [ nip %unbox-struct ] curry "unboxer" set
        "width" get [ nip %box-struct ] curry "boxer" set
        "struct" on
    ] "struct-name" get define-c-type
    "struct-name" get in get init-c-type ;

: c-struct? ( type -- ? )
    c-types get hash [ "struct" swap hash ] [ f ] if* ;
