! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces sequences strings vectors ;

! The basic word type. Words can be named and compared using
! identity. They hold a property map.
DEFER: word?
BUILTIN: word 17 word?
    { 1 hashcode f }
    { 4 "word-def" "set-word-def" }
    { 5 "word-props" "set-word-props" } ;

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

: word-sort ( list -- list )
    #! Sort a list of words by name.
    [ swap word-name swap word-name lexi ] sort ;

! The cross-referencer keeps track of word dependencies, so that
! words can be recompiled when redefined.
SYMBOL: crossref

: (add-crossref)
    dup word? [
        crossref get [ dupd nest set-hash ] bind
    ] [
        2drop
    ] ifte ;

: add-crossref ( word -- )
    #! Marks each word in the quotation as being a dependency
    #! of the word.
    crossref get [
        dup word-def [ (add-crossref) ] tree-each-with
    ] [
        drop
    ] ifte ;

: (remove-crossref)
    dup word? [
        crossref get [ nest remove-hash ] bind
    ] [
        2drop
    ] ifte ;

: remove-crossref ( word -- )
    #! Marks each word in the quotation as not being a
    #! dependency of the word.
    crossref get [
        dup word-def [ (remove-crossref) ] tree-each-with
    ] [
        drop
    ] ifte ;

: usages ( word -- deps )
    #! List all usages of a word. This is a transitive closure,
    #! so indirect usages are reported.
    crossref get dup [ closure word-sort ] [ 2drop { } ] ifte ;

: usage ( word -- list )
    #! List all direct usages of a word.
    crossref get ?hash dup [ hash-keys ] when word-sort ;

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
    over f "picker" set-word-prop
    over f "combination" set-word-prop
    (define-compound) ;

GENERIC: literalize ( obj -- obj )

M: object literalize ;

M: word literalize <wrapper> ;

M: wrapper literalize <wrapper> ;
