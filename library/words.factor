! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces strings ;

BUILTIN: word 17
    [ 1 hashcode f ]
    [ 4 "word-parameter" "set-word-parameter" ]
    [ 5 "word-props" "set-word-props" ] ;

GENERIC: word-xt
M: word word-xt ( w -- xt ) 2 integer-slot ;
GENERIC: set-word-xt
M: word set-word-xt ( xt w -- ) 2 set-integer-slot ;

GENERIC: word-primitive
M: word word-primitive ( w -- n ) 3 integer-slot ;
GENERIC: set-word-primitive
M: word set-word-primitive ( n w -- )
    [ 3 set-integer-slot ] keep update-xt ;

GENERIC: call-count
M: word call-count ( w -- n ) 6 integer-slot ;
GENERIC: set-call-count
M: word set-call-count ( n w -- ) 6 set-integer-slot ;

GENERIC: allot-count
M: word allot-count ( w -- n ) 7 integer-slot ;
GENERIC: set-allot-count
M: word set-allot-count ( n w -- ) 7 set-integer-slot ;

SYMBOL: vocabularies

: word-property ( word pname -- pvalue )
    swap word-props hash ;

: set-word-property ( word pvalue pname -- )
    rot word-props set-hash ;

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

: word-name ( word -- str ) "name" word-property ;

: word-vocabulary ( word -- str ) "vocabulary" word-property ;
