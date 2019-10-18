! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces sequences strings vectors ;

! The basic word type. Words can be named and compared using
! identity. They hold a property map.

: word-prop ( word name -- value ) swap word-props hash ;
: set-word-prop ( word value name -- ) rot word-props set-hash ;

! Pointer to executable native code
GENERIC: word-xt
M: word word-xt ( w -- xt ) 7 integer-slot ;
GENERIC: set-word-xt
M: word set-word-xt ( xt w -- ) 7 set-integer-slot ;

: word-sort ( list -- list )
    #! Sort a list of words by name.
    [ swap word-name swap word-name lexi ] sort ;

: uses ( word -- uses )
    #! Outputs a list of words that this word directly calls.
    [
        dup word-def [
            dup word? [ 2dup eq? [ dup , ] unless ] when 2drop
        ] tree-each-with
    ] { } make prune ;

! The cross-referencer keeps track of word dependencies, so that
! words can be recompiled when redefined.
SYMBOL: crossref

: (add-crossref) crossref get [ dupd nest set-hash ] bind ;

: add-crossref ( word -- )
    #! Marks each word in the quotation as being a dependency
    #! of the word.
    crossref get [
        dup uses [ (add-crossref) ] each-with
    ] [
        drop
    ] ifte ;

: (remove-crossref) crossref get [ nest remove-hash ] bind ;

: remove-crossref ( word -- )
    #! Marks each word in the quotation as not being a
    #! dependency of the word.
    crossref get [
        dup uses [ (remove-crossref) ] each-with
    ] [
        drop
    ] ifte ;

: usages ( word -- deps )
    #! List all usages of a word. This is a transitive closure,
    #! so indirect usages are reported.
    crossref get dup [ closure ] [ 2drop { } ] ifte ;

: usage ( word -- list )
    #! List all direct usages of a word.
    crossref get ?hash dup [ hash-keys ] when ;

GENERIC: (uncrossref) ( word -- )
M: word (uncrossref) drop ;

: uncrossref ( word -- )
    dup (uncrossref) usages [ (uncrossref) ] each ;

! The word primitive combined with the word def specify what the
! word does when invoked.

: define ( word primitive parameter -- )
    pick uncrossref
    pick set-word-def
    over set-word-primitive
    update-xt ;

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

: define-compound ( word def -- )
    >r dup dup remove-crossref r> 1 swap define add-crossref ;

: reset-props ( word seq -- )
    [ f swap set-word-prop ] each-with ;

: reset-word ( word -- )
    {
        "parsing" "inline" "foldable" "flushable" "predicating"
        "documentation" "stack-effect"
    } reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

GENERIC: literalize ( obj -- obj )

M: object literalize ;

M: word literalize <wrapper> ;

M: wrapper literalize <wrapper> ;

: gensym ( -- word )
    #! Return a word that is distinct from every other word, and
    #! is not contained in any vocabulary.
    "G:"
    global [ \ gensym dup inc get ] bind
    number>string append f <word> ;

0 \ gensym global set-hash
