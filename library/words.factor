! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces strings ;

BUILTIN: word 17
    [ 1 hashcode f ]
    [ 4 "word-def" "set-word-def" ]
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

: word-prop ( word name -- value ) swap word-props hash ;
: set-word-prop ( word value name -- ) rot word-props set-hash ;

PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;
PREDICATE: word primitive ( obj -- ? ) word-primitive 2 > ;
PREDICATE: word symbol    ( obj -- ? ) word-primitive 2 = ;
PREDICATE: word undefined ( obj -- ? ) word-primitive 0 = ;

: define ( word primitive parameter -- )
    pick set-word-def
    over set-word-primitive
    f "parsing" set-word-prop ;

: (define-compound) ( word def -- ) 1 swap define ;

: define-compound ( word def -- )
    #! If the word is a generic word, clear the properties 
    #! involved so that 'see' can work properly.
    over f "definer" set-word-prop
    over f "methods" set-word-prop
    over f "combination" set-word-prop
    (define-compound) ;

: define-symbol ( word -- ) 2 over define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] ifte ;

: word-name ( word -- str ) "name" word-prop ;
: word-vocabulary ( word -- str ) "vocabulary" word-prop ;
