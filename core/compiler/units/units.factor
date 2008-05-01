! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations assocs namespaces sequences words
vocabs definitions hashtables init ;
IN: compiler.units

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error boa
    { { "Continue" t } } throw-restarts drop ;

: add-once ( key assoc -- )
    2dup key? [ over redefine-error ] when dupd set-at ;

: (remember-definition) ( definition loc assoc -- )
    >r over set-where r> add-once ;

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: remember-class ( class loc -- )
    over new-definitions get first key? [ dup redefine-error ] when
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
    [ drop word-vocabulary dup [ vocab ] when dup ] assoc-map ;

: updated-definitions ( -- assoc )
    H{ } clone
    dup forgotten-definitions get update
    dup new-definitions get first update
    dup new-definitions get second update
    dup changed-definitions get update
    dup dup changed-vocabs update ;

: compile ( words -- )
    recompile-hook get call
    dup [ drop compiled-crossref? ] assoc-contains?
    modify-code-heap ;

SYMBOL: outdated-tuples
SYMBOL: update-tuples-hook

: call-recompile-hook ( -- )
    changed-definitions get keys [ word? ] filter
    compiled-usages recompile-hook get call ;

: call-update-tuples-hook ( -- )
    update-tuples-hook get call ;

: finish-compilation-unit ( -- )
    call-recompile-hook
    call-update-tuples-hook
    dup [ drop compiled-crossref? ] assoc-contains? modify-code-heap
    updated-definitions notify-definition-observers ;

: with-compilation-unit ( quot -- )
    [
        H{ } clone changed-definitions set
        H{ } clone forgotten-definitions set
        H{ } clone outdated-tuples set
        <definitions> new-definitions set
        <definitions> old-definitions set
        [ finish-compilation-unit ]
        [ ] cleanup
    ] with-scope ; inline

: compile-call ( quot -- )
    [ define-temp ] with-compilation-unit execute ;

: default-recompile-hook ( words -- alist )
    [ f ] { } map>assoc ;

recompile-hook global
[ [ default-recompile-hook ] or ]
change-at
