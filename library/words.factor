! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces strings ;

BUILTIN: word 17

M: word hashcode 1 slot %fixnum ;

: word-xt     ( w -- xt ) >word 2 integer-slot ; inline
: set-word-xt ( xt w -- ) >word 2 set-integer-slot ; inline

: word-primitive ( w -- n ) >word 3 integer-slot ; inline
: set-word-primitive ( n w -- )
    >word [ 3 set-integer-slot ] keep update-xt ; inline

: word-parameter     ( w -- obj ) >word 4 slot ; inline
: set-word-parameter ( obj w -- ) >word 4 set-slot ; inline

: word-props     ( w -- obj ) >word 5 slot ; inline
: set-word-props ( obj w -- ) >word 5 set-slot ; inline

: call-count     ( w -- n ) >word 6 integer-slot ; inline
: set-call-count ( n w -- ) >word 6 set-integer-slot ; inline

: allot-count     ( w -- n ) >word 7 integer-slot ; inline
: set-allot-count ( n w -- ) >word 7 set-integer-slot ; inline

SYMBOL: vocabularies

: word-property ( word pname -- pvalue )
    swap word-props hash ; inline

: set-word-property ( word pvalue pname -- )
    rot word-props set-hash ; inline

PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;
PREDICATE: word primitive ( obj -- ? ) word-primitive 2 > ;
PREDICATE: word symbol    ( obj -- ? ) word-primitive 2 = ;
PREDICATE: word undefined ( obj -- ? ) word-primitive 0 = ;

! These should really be somewhere in library/generic/, but
! during bootstrap, we cannot execute parsing words after they
! are defined by code loaded into the target image.
PREDICATE: compound generic ( word -- ? )
    "combination" word-property ;

PREDICATE: compound promise ( obj -- ? )
    "promise" word-property ;

: define ( word primitive parameter -- )
    pick set-word-parameter
    over set-word-primitive
    f "parsing" set-word-property ;

: define-compound ( word def -- ) 1 swap define ;
: define-symbol   ( word -- ) 2 over define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] ifte ;

#! The type declaration is for the benefit of stack effect
#! inference.
: word-name ( word -- str )
    "name" word-property >string ;

: word-vocabulary ( word -- str ) "vocabulary" word-property ;

: stack-effect    ( word -- str )
    dup "stack-effect" word-property [
        
    ] ?unless ;

: documentation   ( word -- str ) "documentation" word-property ;
