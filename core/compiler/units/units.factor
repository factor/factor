! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel continuations assocs namespaces
sequences words vocabs definitions hashtables init sets
math math.order classes classes.algebra ;
IN: compiler.units

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error boa
    { { "Continue" t } } throw-restarts drop ;

: add-once ( key assoc -- )
    2dup key? [ over redefine-error ] when conjoin ;

: (remember-definition) ( definition loc assoc -- )
    [ over set-where ] dip add-once ;

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: remember-class ( class loc -- )
    [ dup new-definitions get first key? [ dup redefine-error ] when ] dip
    new-definitions get second (remember-definition) ;

: forward-reference? ( word -- ? )
    dup old-definitions get assoc-stack
    [ new-definitions get assoc-stack not ]
    [ drop f ] if ;

SYMBOL: recompile-hook

: <definitions> ( -- pair ) { H{ } H{ } } [ clone ] map ;

SYMBOL: definition-observers

GENERIC: definitions-changed ( assoc obj -- )

[ V{ } clone definition-observers set-global ]
"compiler.units" add-init-hook

: add-definition-observer ( obj -- )
    definition-observers get push ;

: remove-definition-observer ( obj -- )
    definition-observers get delete ;

: notify-definition-observers ( assoc -- )
    definition-observers get
    [ definitions-changed ] with each ;

: changed-vocabs ( assoc -- vocabs )
    [ drop word? ] assoc-filter
    [ drop vocabulary>> dup [ vocab ] when dup ] assoc-map ;

: updated-definitions ( -- assoc )
    H{ } clone
    dup forgotten-definitions get update
    dup new-definitions get first update
    dup new-definitions get second update
    dup changed-definitions get update
    dup dup changed-vocabs update ;

: compile ( words -- )
    recompile-hook get call modify-code-heap ;

SYMBOL: outdated-tuples
SYMBOL: update-tuples-hook
SYMBOL: remake-generics-hook

: dependency>= ( how1 how2 -- ? )
    [
        {
            called-dependency
            flushed-dependency
            inlined-dependency
        } index
    ] bi@ >= ;

: strongest-dependency ( how1 how2 -- how )
    [ called-dependency or ] bi@ [ dependency>= ] most ;

: weakest-dependency ( how1 how2 -- how )
    [ inlined-dependency or ] bi@ [ dependency>= not ] most ;

: compiled-usage ( word -- assoc )
    compiled-crossref get at ;

: (compiled-usages) ( word -- assoc )
    #! If the word is not flushable anymore, we have to recompile
    #! all words which flushable away a call (presumably when the
    #! word was still flushable). If the word is flushable, we
    #! don't have to recompile words that folded this away.
    [ compiled-usage ]
    [ "flushable" word-prop inlined-dependency flushed-dependency ? ] bi
    [ dependency>= nip ] curry assoc-filter ;

: compiled-usages ( assoc -- assocs )
    [ drop word? ] assoc-filter
    [ [ drop (compiled-usages) ] { } assoc>map ] keep suffix ;

: compiled-generic-usage ( word -- assoc )
    compiled-generic-crossref get at ;

: (compiled-generic-usages) ( generic class -- assoc )
    [ compiled-generic-usage ] dip
    [
        2dup [ valid-class? ] both?
        [ classes-intersect? ] [ 2drop f ] if nip
    ] curry assoc-filter ;

: compiled-generic-usages ( assoc -- assocs )
    [ (compiled-generic-usages) ] { } assoc>map ;

: words-only ( assoc -- assoc' )
    [ drop word? ] assoc-filter ;

: to-recompile ( -- seq )
    changed-definitions get compiled-usages
    changed-generics get compiled-generic-usages
    append assoc-combine keys ;

: call-recompile-hook ( -- )
    to-recompile recompile-hook get call ;

: call-remake-generics-hook ( -- )
    remake-generics-hook get call ;

: call-update-tuples-hook ( -- )
    update-tuples-hook get call ;

: unxref-forgotten-definitions ( -- )
    forgotten-definitions get
    keys [ word? ] filter
    [ delete-compiled-xref ] each ;

: finish-compilation-unit ( -- )
    call-remake-generics-hook
    call-recompile-hook
    call-update-tuples-hook
    unxref-forgotten-definitions
    modify-code-heap ;

: with-nested-compilation-unit ( quot -- )
    [
        H{ } clone changed-definitions set
        H{ } clone changed-generics set
        H{ } clone remake-generics set
        H{ } clone outdated-tuples set
        H{ } clone new-classes set
        [ finish-compilation-unit ] [ ] cleanup
    ] with-scope ; inline

: with-compilation-unit ( quot -- )
    [
        H{ } clone changed-definitions set
        H{ } clone changed-generics set
        H{ } clone remake-generics set
        H{ } clone forgotten-definitions set
        H{ } clone outdated-tuples set
        H{ } clone new-classes set
        <definitions> new-definitions set
        <definitions> old-definitions set
        [
            finish-compilation-unit
            updated-definitions
            notify-definition-observers
        ] [ ] cleanup
    ] with-scope ; inline

: compile-call ( quot -- )
    [ define-temp ] with-compilation-unit execute ;

: default-recompile-hook ( words -- alist )
    [ f ] { } map>assoc ;

recompile-hook global
[ [ default-recompile-hook ] or ]
change-at
