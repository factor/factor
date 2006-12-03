! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
DEFER: remove-word-help

IN: words
USING: arrays definitions errors generic graphs hashtables
kernel kernel-internals math namespaces sequences strings
vectors ;

! Used by the compiler
SYMBOL: changed-words

: word-changed? ( word -- ? )
    changed-words get [ hash-member? ] [ drop f ] if* ;

: changed-word ( word -- )
    dup changed-words get [ set-hash ] [ 2drop ] if* ;

: unchanged-word ( word -- )
    changed-words get [ remove-hash ] [ drop ] if* ;

M: word <=>
    [ dup word-name swap word-vocabulary 2array ] 2apply <=> ;

GENERIC: definer ( word -- definer )

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

SYMBOL: vocabularies

: vocab ( name -- vocab ) vocabularies get hash ;

: lookup ( name vocab -- word ) vocab ?hash ;

: target-word ( word -- target )
    dup word-name swap word-vocabulary lookup ;

: interned? ( word -- ? ) dup target-word eq? ;

: uses ( word -- seq )
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

: reset-props ( word seq -- ) [ remove-word-prop ] each-with ;

: custom-infer? ( word -- ? )
    dup "infer" word-prop swap "infer-vars" word-prop or ;

: unxref-word* ( word -- )
    {
        { [ dup compound? not ] [ drop ] }
        { [ dup custom-infer? ] [ drop ] }
        { [ t ] [
            dup changed-word
            {
                "inferred-effect" "inferred-vars"
                "base-case" "no-effect"
            } reset-props
        ] }
    } cond ;

: unxref-word ( word -- )
    dup [ usage ] closure [ unxref-word* ] each
    [ uses ] crossref get remove-vertex ;

: define ( word def primitive -- )
    pick changed-word
    pick unxref-word
    pick set-word-primitive
    over set-word-def
    dup update-xt
    xref-word ;

: define-symbol ( word -- )
    dup symbol? [ drop ] [ dup 2 define ] if ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] if ;

: define-compound ( word def -- ) 1 define ;

: reset-word ( word -- )
    {
        "parsing" "inline" "foldable"
        "predicating" "declared-effect"
    } reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

: <word> ( name vocab -- word ) (word) dup init-word ;

: gensym ( -- word )
    "G:" \ gensym counter number>string append f <word> ;

: define-temp ( quot -- word )
    gensym [ swap define-compound ] keep ;

SYMBOL: bootstrapping?

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

: vocabs ( -- seq ) vocabularies get hash-keys natural-sort ;

: ensure-vocab ( name -- ) vocabularies get [ nest drop ] bind ;

: words ( vocab -- seq ) vocab dup [ hash-values ] when ;

: all-words ( -- seq )
    vocabularies get hash-values [ hash-values ] map concat ;

: word-subset ( quot -- seq )
    all-words swap subset ; inline

: word-subset-with ( obj quot -- seq )
    all-words swap subset-with ; inline

: xref-words ( -- )
    all-words [ uses ] crossref get build-graph ;

: create-vocab ( name -- vocab )
    vocabularies get [ nest ] bind ;

: reveal ( word -- )
    dup word-name over word-vocabulary create-vocab set-hash ;

TUPLE: check-create name vocab ;
: check-create ( name vocab -- name vocab )
    dup string? [ <check-create> throw ] unless
    over string? [ <check-create> throw ] unless ;

: create ( name vocab -- word )
    check-create 2dup lookup dup
    [ 2nip ] [ drop <word> dup reveal ] if ;

: constructor-word ( name vocab -- word )
    >r "<" swap ">" append3 r> create ;

: forget-vocab ( vocab -- )
    words [ forget ] each ;

: bootstrap-word ( word -- target )
    bootstrapping? get [
        dup word-name swap word-vocabulary
        dup "syntax" = [ [ CHAR: ! add* ] 2apply ] when lookup
    ] when ;

: words-named ( str -- seq )
    all-words [ word-name = ] subset-with ;

! Definition protocol
M: word where "loc" word-prop ;

M: word subdefs drop f ;

: forget-word ( word -- )
    dup unxref-word
    dup remove-word-help
    dup unchanged-word
    crossref get [ dupd remove-hash ] when*
    dup word-name swap word-vocabulary vocab remove-hash ;

M: word forget forget-word ;
