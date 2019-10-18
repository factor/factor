! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private math
namespaces parser sequences strings words libc slots
alien.c-types math.functions math.vectors cpu.architecture ;
IN: alien.structs

: align-offset ( offset type -- offset )
    c-type c-type-align align ;

: struct-offsets ( specs -- size )
    0 [
        [ slot-spec-type align-offset ] keep
        [ set-slot-spec-offset ] 2keep
        slot-spec-type heap-size +
    ] reduce ;

: define-struct-slot-word ( spec word quot -- )
    rot slot-spec-offset add* define-inline ;

: define-getter ( type spec -- )
    [ set-reader-props ] keep
    dup slot-spec-reader
    over slot-spec-type c-getter
    define-struct-slot-word ;

: define-setter ( type spec -- )
    [ set-writer-props ] keep
    dup slot-spec-writer
    over slot-spec-type c-setter
    define-struct-slot-word ;

: define-field ( type spec -- )
    2dup define-getter define-setter ;

: if-value-structs? ( ctype true false -- )
    value-structs?
    [ drop call ] [ >r 2drop "void*" r> call ] if ; inline

TUPLE: struct-type size align fields ;

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

: (define-struct) ( name vocab size align fields -- )
    >r [ align ] keep r>
    struct-type construct-boa
    -rot define-c-type ;

: make-field ( struct-name vocab type field-name -- spec )
    [
        -rot expand-constants ,
        over ,
        3dup reader-word ,
        writer-word ,
    ] { } make
    first4 0 -rot <slot-spec> ;

: define-struct-early ( name vocab fields -- fields )
    -rot [ rot first2 make-field ] 2curry map ;

: compute-struct-align ( types -- n )
    [ c-type-align ] map supremum ;

: define-struct ( name vocab fields -- )
    pick >r
    [ struct-offsets ] keep
    [ [ slot-spec-type ] map compute-struct-align ] keep
    [ (define-struct) ] keep
    r> [ swap define-field ] curry each ;

: define-union ( name vocab members -- )
    [ expand-constants ] map
    [ [ heap-size ] map supremum ] keep
    compute-struct-align f (define-struct) ;
