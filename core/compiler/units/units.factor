! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel continuations assocs namespaces
sequences words vocabs definitions hashtables init sets math
math.order classes classes.private classes.algebra classes.tuple
classes.tuple.private generic source-files.errors kernel.private ;
FROM: namespaces => set ;
IN: compiler.units

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error boa throw-continue ;

<PRIVATE

: add-once ( key assoc -- )
    2dup key? [ over redefine-error ] when conjoin ;

: (remember-definition) ( definition loc assoc -- )
    [ over set-where ] dip add-once ;

PRIVATE>

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: fake-definition ( definition -- )
    old-definitions get [ delete-at ] with each ;

: remember-class ( class loc -- )
    [ dup new-definitions get first key? [ dup redefine-error ] when ] dip
    new-definitions get second (remember-definition) ;

: forward-reference? ( word -- ? )
    dup old-definitions get assoc-stack
    [ new-definitions get assoc-stack not ]
    [ drop f ] if ;

SYMBOL: compiler-impl

HOOK: update-call-sites compiler-impl ( class generic -- words )

: changed-call-sites ( class generic -- )
    update-call-sites [ changed-definition ] each ;

M: generic update-generic ( class generic -- )
    [ changed-call-sites ]
    [ remake-generic drop ]
    [ changed-conditionally drop ]
    2tri ;

M: sequence update-methods ( class seq -- )
    implementors [ update-generic ] with each ;

HOOK: recompile compiler-impl ( words -- alist )

HOOK: to-recompile compiler-impl ( -- words )

HOOK: process-forgotten-words compiler-impl ( words -- )

: compile ( words -- )
    recompile t f modify-code-heap ;

! Non-optimizing compiler
M: f update-call-sites
    2drop { } ;

M: f to-recompile
    changed-definitions get [ drop word? ] assoc-filter keys ;

M: f recompile
    [ dup def>> ] { } map>assoc ;

M: f process-forgotten-words drop ;

: without-optimizer ( quot -- )
    [ f compiler-impl ] dip with-variable ; inline

: <definitions> ( -- pair ) { H{ } H{ } } [ clone ] map ;

SYMBOL: definition-observers

GENERIC: definitions-changed ( assoc obj -- )

[ V{ } clone definition-observers set-global ]
"compiler.units" add-startup-hook

! This goes here because vocabs cannot depend on init
[ V{ } clone vocab-observers set-global ]
"vocabs" add-startup-hook

: add-definition-observer ( obj -- )
    definition-observers get push ;

: remove-definition-observer ( obj -- )
    definition-observers get remove-eq! drop ;

: notify-definition-observers ( assoc -- )
    definition-observers get
    [ definitions-changed ] with each ;

! Incremented each time stack effects potentially changed, used
! by compiler.tree.propagation.call-effect for call( and execute(
! inline caching
: effect-counter ( -- n ) 49 special-object ; inline

GENERIC: always-bump-effect-counter? ( defspec -- ? )

M: object always-bump-effect-counter? drop f ;

<PRIVATE

: changed-vocabs ( assoc -- vocabs )
    [ drop word? ] assoc-filter
    [ drop vocabulary>> dup [ lookup-vocab ] when dup ] assoc-map ;

: updated-definitions ( -- assoc )
    H{ } clone
    forgotten-definitions get assoc-union!
    new-definitions get first assoc-union!
    new-definitions get second assoc-union!
    changed-definitions get assoc-union!
    maybe-changed get assoc-union!
    dup changed-vocabs assoc-union! ;

: process-forgotten-definitions ( -- )
    forgotten-definitions get keys
    [ [ word? ] filter process-forgotten-words ]
    [ [ delete-definition-errors ] each ]
    bi ;

: bump-effect-counter? ( -- ? )
    changed-effects get
    maybe-changed get
    changed-definitions get [ drop always-bump-effect-counter? ] assoc-filter
    3array assoc-combine new-words get assoc-diff assoc-empty? not ;

: bump-effect-counter ( -- )
    bump-effect-counter? [
        49 special-object 0 or
        1 +
        49 set-special-object
    ] when ;

: notify-observers ( -- )
    updated-definitions dup assoc-empty?
    [ drop ] [ notify-definition-observers notify-error-observers ] if ;

: update-existing? ( defs -- ? )
    new-words get keys diff empty? not ;

: reset-pics? ( -- ? )
    outdated-generics get assoc-empty? not ;

: finish-compilation-unit ( -- )
    [ ] [
        remake-generics
        to-recompile [
            recompile
            update-tuples
            process-forgotten-definitions
        ] keep update-existing? reset-pics? modify-code-heap
        bump-effect-counter
        notify-observers
    ] if-bootstrapping ;

TUPLE: nesting-observer new-words ;

M: nesting-observer definitions-changed new-words>> swap assoc-diff! drop ;

: add-nesting-observer ( -- )
    new-words get nesting-observer boa
    [ nesting-observer set ] [ add-definition-observer ] bi ;

: remove-nesting-observer ( -- )
    nesting-observer get remove-definition-observer ;

PRIVATE>

: with-nested-compilation-unit ( quot -- )
    [
        H{ } clone changed-definitions set
        H{ } clone maybe-changed set
        H{ } clone changed-effects set
        H{ } clone outdated-generics set
        H{ } clone outdated-tuples set
        H{ } clone new-words set
        add-nesting-observer
        [
            remove-nesting-observer
            finish-compilation-unit
        ] [ ] cleanup
    ] with-scope ; inline

: with-compilation-unit ( quot -- )
    [
        <definitions> new-definitions set
        <definitions> old-definitions set
        H{ } clone forgotten-definitions set
        with-nested-compilation-unit
    ] with-scope ; inline
