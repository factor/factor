! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs generic hashtables kernel kernel.private
math namespaces parser sequences strings words libc fry
alien.c-types alien.structs.fields cpu.architecture math.order
quotations byte-arrays ;
IN: alien.structs

TUPLE: struct-type < abstract-c-type fields return-in-registers? ;

INSTANCE: struct-type value-type

M: struct-type c-type ;

M: struct-type c-type-stack-align? drop f ;

: if-value-struct ( ctype true false -- )
    [ dup value-struct? ] 2dip '[ drop void* @ ] if ; inline

M: struct-type unbox-parameter
    [ %unbox-large-struct ] [ unbox-parameter ] if-value-struct ;

M: struct-type box-parameter
    [ %box-large-struct ] [ box-parameter ] if-value-struct ;

: if-small-struct ( c-type true false -- ? )
    [ dup return-struct-in-registers? ] 2dip '[ f swap @ ] if ; inline

M: struct-type unbox-return
    [ %unbox-small-struct ] [ %unbox-large-struct ] if-small-struct ;

M: struct-type box-return
    [ %box-small-struct ] [ %box-large-struct ] if-small-struct ;

M: struct-type stack-size
    [ heap-size ] [ stack-size ] if-value-struct ;

M: struct-type c-struct? drop t ;

: (define-struct) ( name size align fields class -- )
    [ [ align ] keep ] 2dip new
        byte-array >>class
        byte-array >>boxed-class
        swap >>fields
        swap >>align
        swap >>size
        swap typedef ;

: make-fields ( name vocab fields -- fields )
    [ first2 <field-spec> ] with with map ;

: compute-struct-align ( types -- n )
    [ c-type-align ] [ max ] map-reduce ;

: define-struct ( name vocab fields -- )
    [ 2drop ] [ make-fields ] 3bi
    [ struct-offsets ] keep
    [ [ type>> ] map compute-struct-align ] keep
    [ struct-type (define-struct) ] keep
    [ define-field ] each ; deprecated

: define-union ( name members -- )
    [ [ heap-size ] [ max ] map-reduce ] keep
    compute-struct-align f struct-type (define-struct) ; deprecated

: offset-of ( field struct -- offset )
    c-types get at fields>> 
    [ name>> = ] with find nip offset>> ;

USE: vocabs.loader
"specialized-arrays" require
