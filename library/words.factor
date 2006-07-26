! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
DEFER: remove-word-help

IN: words
USING: arrays errors graphs hashtables kernel kernel-internals
math namespaces sequences strings vectors ;

M: word <=>
    [ dup word-name swap word-vocabulary 2array ] 2apply <=> ;

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

SYMBOL: vocabularies

: vocab ( name -- vocab ) vocabularies get hash ;

: lookup ( name vocab -- word ) vocab ?hash ;

: target-word ( word -- word )
    dup word-name swap word-vocabulary lookup ;

: interned? ( word -- ? ) dup target-word eq? ;

: uses ( word -- uses )
    word-def flatten
    [ word? ] subset
    [ global [ interned? ] bind ] subset
    prune ;

SYMBOL: crossref

: xref-word ( word -- )
    dup word-vocabulary [
        [ uses ] crossref get add-vertex
    ] [
        drop
    ] if ;

: usage ( word -- seq ) crossref get in-edges ;

GENERIC: unxref-word* ( word -- )

M: word unxref-word* drop ;

: unxref-word ( word -- )
    dup [ usage ] closure [ unxref-word* ] each
    [ uses ] crossref get remove-vertex ;

: define ( word parameter primitive -- )
    pick unxref-word
    pick set-word-primitive
    over set-word-def
    dup update-xt
    xref-word ;

: define-symbol ( word -- ) dup 2 define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] if ;

: define-compound ( word def -- ) 1 define ;

: reset-props ( word seq -- ) [ remove-word-prop ] each-with ;

: reset-word ( word -- )
    { "parsing" "inline" "foldable" "predicating" } reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

: <word> ( name vocab -- word ) (word) dup init-word ;

: gensym ( -- word )
    "G:" \ gensym counter number>string append f <word> ;

: define-temp ( quot -- word )
    gensym [ swap define-compound ] keep ;

: completions ( substring words -- seq )
    [ word-name subseq? ] subset-with ;

SYMBOL: bootstrapping?

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

: vocabs ( -- seq ) vocabularies get hash-keys natural-sort ;

: ensure-vocab ( name -- ) vocabularies get [ nest drop ] bind ;

: words ( vocab -- list ) vocab dup [ hash-values ] when ;

: all-words ( -- list ) vocabs [ words ] map concat ;

: word-subset ( pred -- list )
    all-words swap subset ; inline

: word-subset-with ( obj pred -- list | pred: obj word -- ? )
    all-words swap subset-with ; inline

: xref-words ( -- )
    all-words [ uses ] crossref get build-graph ;

: reveal ( word -- )
    vocabularies get [
        dup word-name over word-vocabulary nest set-hash
    ] bind ;

: check-create ( name vocab -- )
    string? [ "Vocabulary name is not a string" throw ] unless
    string? [ "Word name is not a string" throw ] unless ;

: create ( name vocab -- word )
    2dup check-create 2dup lookup dup
    [ 2nip ] [ drop <word> dup reveal ] if ;

: constructor-word ( string vocab -- word )
    >r "<" swap ">" append3 r> create ;

: forget ( word -- )
    dup unxref-word
    dup remove-word-help
    dup "forget-hook" word-prop call
    crossref get [ dupd remove-hash ] when*
    dup word-name swap word-vocabulary vocab remove-hash ;

: forget-vocab ( vocab -- )
    words [ forget ] each ;

: bootstrap-word ( word -- word )
    bootstrapping? get [
        dup word-name swap word-vocabulary
        dup "syntax" = [
            drop "!syntax" >r "!" swap append r>
        ] when lookup
    ] when ;
