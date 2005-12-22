! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic hashtables kernel kernel-internals lists math
namespaces sequences strings vectors ;

: init-word ( word -- )
    H{ } clone swap set-word-props ;

! The basic word type. Words can be named and compared using
! identity. They hold a property map.

: word-prop ( word name -- value )
    swap word-props hash ;

: set-word-prop ( word value name -- )
    rot word-props pick [ set-hash ] [ remove-hash drop ] if ;

! Pointer to executable native code
GENERIC: word-xt
M: word word-xt ( w -- xt ) 7 integer-slot ;

GENERIC: set-word-xt
M: word set-word-xt ( xt w -- ) 7 set-integer-slot ;

: word-sort ( list -- list )
    #! Sort a list of words by name.
    [ [ word-name ] 2apply lexi ] sort ;

: uses ( word -- uses )
    #! Outputs a list of words that this word directly calls.
    [
        dup word-def [
            dup word?
            [ 2dup eq? [ dup dup set ] unless ] when
            2drop
        ] tree-each-with
    ] make-hash hash-keys ;

! The cross-referencer keeps track of word dependencies, so that
! words can be recompiled when redefined.
SYMBOL: crossref

: (add-crossref) crossref get [ dupd nest set-hash ] bind ;

: add-crossref ( word -- )
    #! Marks each word in the quotation as being a dependency
    #! of the word.
    crossref get [
        dup dup uses [ (add-crossref) ] each-with
    ] when drop ;

: usages ( word -- deps )
    #! List all usages of a word. This is a transitive closure,
    #! so indirect usages are reported.
    crossref get dup [ closure ] [ 2drop { } ] if ;

: usage ( word -- list )
    #! List all direct usages of a word.
    crossref get ?hash dup [ hash-keys ] when ;

GENERIC: (uncrossref) ( word -- )

M: word (uncrossref) drop ;

: remove-crossref ( usage user -- )
    crossref get [ nest remove-hash ] bind ;

: uncrossref ( word -- )
    crossref get [
        dup dup uses [ remove-crossref ] each-with
        dup (uncrossref) dup usages [ (uncrossref) ] each
    ] when drop ;

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
    dup undefined? [ define-symbol ] [ drop ] if ;

! Compound words invoke a quotation when executed.
PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;
M: compound definer drop \ : ;

: define-compound ( word def -- )
    over >r 1 swap define r> add-crossref ;

: reset-props ( word seq -- )
    [ f swap set-word-prop ] each-with ;

: reset-word ( word -- )
    {
        "parsing" "inline" "foldable" "flushable" "predicating"
        "documentation" "stack-effect"
    } reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

M: word literalize <wrapper> ;

: gensym ( -- word )
    #! Return a word that is distinct from every other word, and
    #! is not contained in any vocabulary.
    "G:"
    global [ \ gensym dup inc get ] bind
    number>string append f <word> dup init-word ;

0 \ gensym set-global
