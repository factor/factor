! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays generator errors generic hashtables kernel
kernel-internals math namespaces parser sequences strings
words libc ;

! Some code for interfacing with C structures.
: define-struct-slot-word ( offset word quot -- )
    rot add* define-compound ;

: define-getter ( offset type reader -- )
    #! Define a word with stack effect ( alien -- obj ) in the
    #! current 'in' vocabulary.
    swap c-getter define-struct-slot-word ;

: define-setter ( offset type writer -- )
    #! Define a word with stack effect ( obj alien -- ) in the
    #! current 'in' vocabulary.
    swap c-setter define-struct-slot-word ;

: align-offset ( offset type -- offset )
    c-type c-type-align align ;

: define-field ( offset type reader writer -- offset )
    >r >r [ align-offset ] keep 2dup
    r> define-getter 2dup
    r> define-setter
    heap-size + ;

: if-value-structs? ( ctype true false -- )
    value-structs?
    [ drop call ] [ >r 2drop "void*" r> call ] if ; inline

TUPLE: struct-type size align ;

C: struct-type ( width align -- type )
    [ set-struct-type-align ] keep
    [ set-struct-type-size ] keep ;

M: struct-type heap-size struct-type-size ;

M: struct-type c-type-align struct-type-align ;

M: struct-type c-type-stack-align? drop f ;

M: struct-type unbox-parameter
    [ heap-size %unbox-struct ]
    [ unbox-parameter ]
    if-value-structs? ;

M: struct-type unbox-return
    f swap heap-size %unbox-struct ;

M: struct-type box-parameter
    [ heap-size %box-struct ]
    [ box-parameter ]
    if-value-structs? ;

M: struct-type box-return
    f swap heap-size %box-struct ;

M: struct-type stack-size
    [ heap-size ] [ stack-size ] if-value-structs? ;

: c-struct? ( type -- ? ) (c-type) struct-type? ;

: (define-struct) ( name vocab width align -- )
    [ align ] keep <struct-type> -rot define-c-type ;

: define-union ( name vocab members -- )
    dup [ heap-size ] map supremum
    swap [ c-type-align ] map supremum (define-struct) ;

: define-struct-early ( name vocab fields -- fields )
    #! Just defer the words so that we have accessors at
    #! parse time
    [
        pick pick >r >r first2 r> swap r>
        [ reader-word ] 3keep writer-word
        3array
    ] map 2nip ;

: define-struct ( name vocab fields -- )
    [ 0 [ first3 define-field ] reduce ] keep
    [ first c-type-align ] map supremum (define-struct) ;

UNION: value-type array struct-type ;

M: array c-type ;

M: array heap-size unclip heap-size [ * ] reduce ;

M: array c-type-align first c-type c-type-align ;

M: array c-type-stack-align? drop f ;

M: array unbox-parameter drop "void*" unbox-parameter ;

M: array unbox-return drop "void*" unbox-return ;

M: array box-parameter drop "void*" box-parameter ;

M: array box-return drop "void*" box-return ;

M: array stack-size drop "void*" stack-size ;

M: value-type c-type-reg-class drop T{ int-regs } ;

M: value-type c-type-prep drop f ;

M: value-type c-type-getter
    drop [ swap <displaced-alien> ] ;

M: value-type c-type-setter ( type -- quot )
    [
        dup c-type-getter % \ swap , heap-size , \ memcpy ,
    ] [ ] make ;
