! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic hashtables kernel kernel.private
math namespaces parser sequences strings words libc
alien.c-types alien.structs.fields cpu.architecture ;
IN: alien.structs

: if-value-structs? ( ctype true false -- )
    value-structs?
    [ drop call ] [ >r 2drop "void*" r> call ] if ; inline

TUPLE: struct-type size align fields ;

M: struct-type heap-size size>> ;

M: struct-type c-type-align align>> ;

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

: (define-struct) ( name vocab size align fields -- )
    >r [ align ] keep r>
    struct-type boa
    -rot define-c-type ;

: define-struct-early ( name vocab fields -- fields )
    -rot [ rot first2 <field-spec> ] 2curry map ;

: compute-struct-align ( types -- n )
    [ c-type-align ] map supremum ;

: define-struct ( name vocab fields -- )
    pick >r
    [ struct-offsets ] keep
    [ [ type>> ] map compute-struct-align ] keep
    [ (define-struct) ] keep
    r> [ swap define-field ] curry each ;

: define-union ( name vocab members -- )
    [ expand-constants ] map
    [ [ heap-size ] map supremum ] keep
    compute-struct-align f (define-struct) ;
