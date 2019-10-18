! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
DEFER: remove-word-help

IN: words
USING: arrays definitions errors generic graphs assocs
kernel kernel-internals math namespaces sequences strings
vectors sbufs quotations assocs hashtables ;

! Used by the compiler
SYMBOL: changed-words

: word-changed? ( word -- ? )
    changed-words get [ key? ] [ drop f ] if* ;

: changed-word ( word -- )
    dup changed-words get [ set-at ] [ 2drop ] if* ;

: unchanged-word ( word -- )
    changed-words get [ delete-at ] [ drop ] if* ;

M: word <=>
    [ dup word-name swap word-vocabulary 2array ] 2apply <=> ;

M: word definition drop f ;

PREDICATE: word undefined ( obj -- ? ) word-primitive 0 = ;
M: undefined definer drop \ DEFER: f ;

PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;

M: compound definer drop \ : \ ; ;

M: compound definition word-def ;

PREDICATE: word primitive ( obj -- ? ) word-primitive 2 > ;
M: primitive definer drop \ PRIMITIVE: f ;

PREDICATE: word symbol    ( obj -- ? ) word-primitive 2 = ;
M: symbol definer drop \ SYMBOL: f ;

: word-prop ( word name -- value ) swap word-props at ;

: remove-word-prop ( word name -- )
    swap word-props delete-at ;

: set-word-prop ( word value name -- )
    over
    [ pick word-props ?set-at swap set-word-props ]
    [ nip remove-word-prop ] if ;

SYMBOL: vocabularies

: vocab ( name -- vocab ) vocabularies get at ;

: lookup ( name vocab -- word ) vocab at ;

: target-word ( word -- target )
    dup word-name swap word-vocabulary lookup ;

: interned? ( word -- ? ) dup target-word eq? ;

GENERIC: (quot-uses) ( hash obj -- )

M: object (quot-uses) 2drop ;

: seq-quot-uses [ (quot-uses) ] each-with ;

M: word (quot-uses)
    dup interned? [ dup rot set-at ] [ 2drop ] if ;

M: array (quot-uses) seq-quot-uses ;

M: quotation (quot-uses) seq-quot-uses ;

M: wrapper (quot-uses) wrapped (quot-uses) ;

: quot-uses ( quot -- hash )
    global [
        H{ } clone [ swap (quot-uses) ] keep
    ] bind ;

: uses ( word -- seq )
    word-def quot-uses keys ;

SYMBOL: crossref

: xref-word ( word -- )
    dup word-vocabulary [
        [ uses ] crossref get add-vertex
    ] [
        drop
    ] if ;

: usage ( word -- seq ) crossref get in-edges ;

: reset-props ( word seq -- ) [ remove-word-prop ] each-with ;

: unxref-word* ( word -- )
    dup compound? [
        dup changed-word
        dup {
            "inferred-effect" "inferred-vars"
            "base-case" "no-effect"
        } reset-props
    ] when drop ;

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

: define-declared ( word def effect -- )
    pick swap "declared-effect" set-word-prop
    define-compound ;

: (inline) ( word -- ) t "inline" set-word-prop ;

: define-inline ( word quot -- ) dupd define-compound (inline) ;

: reset-word ( word -- )
    {
        "parsing" "inline" "foldable"
        "predicating" "reading" "writing" "constructing"
        "declared-effect" "constructor-quot" "delimiter"
    } reset-props ;

: reset-generic ( word -- )
    dup reset-word { "methods" "combination" } reset-props ;

: gensym ( -- word )
    "G:" \ gensym counter number>string append f <word> ;

: define-temp ( quot -- word )
    gensym [ swap define-compound ] keep ;

SYMBOL: bootstrapping?

: if-bootstrapping ( true false -- )
    bootstrapping? get -rot if ; inline

: word ( -- word ) \ word get-global ;

: set-word ( word -- ) \ word set-global ;

: vocabs ( -- seq ) vocabularies get keys natural-sort ;

: words ( vocab -- seq ) vocab dup [ values ] when ;

: all-words ( -- seq )
    vocabularies get values [ values ] map concat ;

: xref-words ( -- )
    all-words [ uses ] crossref get build-graph ;

: create-vocab ( name -- vocab )
    vocabularies get [ drop H{ } clone ] cache ;

: reveal ( word -- )
    dup word-name over word-vocabulary create-vocab set-at ;

TUPLE: check-create name vocab ;
: check-create ( name vocab -- name vocab )
    dup string? [ <check-create> throw ] unless
    over string? [ <check-create> throw ] unless ;

: create ( name vocab -- word )
    check-create 2dup lookup dup
    [ 2nip ] [ drop <word> dup reveal ] if ;

: constructor-word ( name vocab -- word )
    >r "<" swap ">" 3append r> create ;

: parsing? ( obj -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

: delimiter? ( obj -- ? )
    dup word? [ "delimiter" word-prop ] [ drop f ] if ;

: forget-vocab ( vocab -- )
    words [ forget ] each ;

: bootstrap-word ( word -- target )
    [
        dup word-name swap word-vocabulary
        dup "syntax" = [ [ CHAR: ! add* ] 2apply ] when lookup
    ] [ ] if-bootstrapping ;

: words-named ( str -- seq )
    vocabularies get values [ at ] map-with [ ] subset ;

! Definition protocol
M: word where "loc" word-prop ;

: forget-word ( word -- )
    dup unxref-word
    dup remove-word-help
    dup unchanged-word
    crossref get [ dupd delete-at ] when*
    dup word-name swap word-vocabulary vocab delete-at ;

M: word forget forget-word ;

M: word hashcode*
    nip 1 slot { fixnum } declare ;
