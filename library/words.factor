! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: hashtables kernel kernel-internals lists math
namespaces sequences strings vectors ;

M: word <=> [ word-name ] 2apply <=> ;

GENERIC: definer ( word -- word )

PREDICATE: word undefined ( obj -- ? ) word-primitive 0 = ;
M: undefined definer drop \ DEFER: ;

PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;
M: compound definer drop \ : ;

PREDICATE: word primitive ( obj -- ? ) word-primitive 2 > ;
M: primitive definer drop \ PRIMITIVE: ;

PREDICATE: word symbol    ( obj -- ? ) word-primitive 2 = ;
M: symbol definer drop \ SYMBOL: ;

: init-word ( word -- ) H{ } clone swap set-word-props ;

: word-prop ( word name -- value ) swap word-props hash ;

: remove-word-prop ( word name -- )
    swap word-props remove-hash ;

: set-word-prop ( word value name -- )
    over
    [ rot word-props set-hash ]
    [ nip remove-word-prop ] if ;

GENERIC: word-xt
M: word word-xt ( w -- xt ) 7 integer-slot ;

GENERIC: set-word-xt
M: word set-word-xt ( xt w -- ) 7 set-integer-slot ;

: uses ( word -- uses )
    word-def flatten [ word? ] subset prune ;

SYMBOL: crossref

: (add-crossref) crossref get [ dupd nest set-hash ] bind ;

: add-crossref ( word -- )
    crossref get over interned? and [
        dup dup uses [ (add-crossref) ] each-with
    ] when drop ;

: usage ( word -- seq )
    crossref get ?hash dup [ hash-keys ] when ;

: usages ( word -- deps )
    crossref get dup [ closure ] [ 2drop { } ] if ;

GENERIC: (uncrossref) ( word -- )

M: word (uncrossref) drop ;

: remove-crossref ( callee caller -- )
    crossref get [ nest remove-hash ] bind ;

: uncrossref ( word -- )
    crossref get [
        dup dup uses [ remove-crossref ] each-with
        dup (uncrossref) dup usages [ (uncrossref) ] each
    ] when drop ;

: define ( word parameter primitive -- )
    pick uncrossref
    pick set-word-primitive
    over set-word-def
    dup update-xt
    add-crossref ;

: define-symbol ( word -- ) dup 2 define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] if ;

: define-compound ( word def -- ) 1 define ;

: reset-props ( word seq -- ) [ remove-word-prop ] each-with ;

: reset-word ( word -- )
    { "parsing" "inline" "foldable" "flushable" "predicating" }
    reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

M: word literalize <wrapper> ;

: gensym ( -- word )
    [ "G:" % \ gensym counter # ] "" make
    f <word> dup init-word ;

: completions ( substring words -- seq )
    [ word-name subseq? ] subset-with ;
