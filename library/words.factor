! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces sequences strings vectors ;

! The basic word type. Words can be named and compared using
! identity. They hold a property map.
BUILTIN: word 17
    [ 1 hashcode f ]
    [ 4 "word-def" "set-word-def" ]
    [ 5 "word-props" "set-word-props" ] ;

: word-prop ( word name -- value ) swap word-props hash ;
: set-word-prop ( word value name -- ) rot word-props set-hash ;

: word-name ( word -- str ) "name" word-prop ;
: word-vocabulary ( word -- str ) "vocabulary" word-prop ;

! Pointer to executable native code
GENERIC: word-xt
M: word word-xt ( w -- xt ) 2 integer-slot ;
GENERIC: set-word-xt
M: word set-word-xt ( xt w -- ) 2 set-integer-slot ;

! Primitive number; some are magic, see below.
GENERIC: word-primitive
M: word word-primitive ( w -- n ) 3 integer-slot ;
GENERIC: set-word-primitive
M: word set-word-primitive ( n w -- )
    [ 3 set-integer-slot ] keep update-xt ;

! For the profiler
GENERIC: call-count
M: word call-count ( w -- n ) 6 integer-slot ;
GENERIC: set-call-count
M: word set-call-count ( n w -- ) 6 set-integer-slot ;

GENERIC: allot-count
M: word allot-count ( w -- n ) 7 integer-slot ;
GENERIC: set-allot-count
M: word set-allot-count ( n w -- ) 7 set-integer-slot ;

! The cross-referencer keeps track of word dependencies, so that
! words can be recompiled when redefined.
SYMBOL: crossref

global [ <namespace> crossref set ] bind

: (add-crossref)
    dup word? [
        crossref get [ dupd nest set-hash ] bind
    ] [
        2drop
    ] ifte ;

: add-crossref ( word -- )
    #! Marks each word in the quotation as being a dependency
    #! of the word.
    dup word-def [ (add-crossref) ] tree-each-with ;

: (remove-crossref)
    dup word? [
        crossref get [ nest remove-hash ] bind
    ] [
        2drop
    ] ifte ;

: remove-crossref ( word -- )
    #! Marks each word in the quotation as not being a
    #! dependency of the word.
    dup word-def [ (remove-crossref) ] tree-each-with ;

: usages ( word -- deps )
    #! The transitive closure over the relation specified in
    #! the crossref hash.
    crossref get closure  ;

GENERIC: (uncrossref) ( word -- )
M: word (uncrossref) drop ;

: uncrossref ( word -- )
    dup (uncrossref) usages  [ (uncrossref) ] each ;

! The word primitive combined with the word def specify what the
! word does when invoked.

: define ( word primitive parameter -- )
    pick uncrossref
    pick set-word-def
    over set-word-primitive
    f "parsing" set-word-prop ;

GENERIC: definer ( word -- word )
#! Return the parsing word that defined this word.

! Undefined words raise an error when invoked.
PREDICATE: word undefined ( obj -- ? ) word-primitive 0 = ;
M: undefined definer drop \ DEFER: ;

! Primitives are defined in the runtime.
PREDICATE: word primitive ( obj -- ? ) word-primitive 2 > ;
M: primitive definer drop \ PRIMITIVE: ;

! Symbols push themselves when executed.
PREDICATE: word symbol    ( obj -- ? ) word-primitive 2 = ;
M: symbol definer drop \ SYMBOL: ;

: define-symbol ( word -- ) 2 over define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] ifte ;

! Compound words invoke a quotation when executed.
PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;
M: compound definer drop \ : ;

: (define-compound) ( word def -- )
    >r dup dup remove-crossref r> 1 swap define add-crossref ;

: define-compound ( word def -- )
    #! If the word is a generic word, clear the properties 
    #! involved so that 'see' can work properly.
    over f "methods" set-word-prop
    over f "combination" set-word-prop
    (define-compound) ;
