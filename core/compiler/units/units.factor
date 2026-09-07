! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.private
classes.tuple.private continuations definitions generic
hash-sets kernel kernel.private math namespaces sequences
sets source-files.errors vocabs words ;
IN: compiler.units

PRIMITIVE: modify-code-heap ( alist update-existing? reset-pics? -- )

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: throw-redefine-error ( definition -- )
    redefine-error boa throw-continue ;

<PRIVATE

: add-once ( key set -- )
    dupd ?adjoin [ drop ] [ throw-redefine-error ] if ;

: (remember-definition) ( definition loc set -- )
    [ over set-where ] dip add-once ;

PRIVATE>

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: fake-definition ( definition -- )
    old-definitions get [ delete ] with each ;

: remember-class ( class loc -- )
    new-definitions get first2
    [ dupd in? [ dup throw-redefine-error ] when ]
    [ (remember-definition) ] bi-curry* bi* ;

: forward-reference? ( word -- ? )
    dup old-definitions get [ in? ] with any? [
        new-definitions get [ in? ] with none?
    ] [ drop f ] if ;

SYMBOL: compiler-impl

HOOK: update-call-sites compiler-impl ( class generic -- words )

: changed-call-sites ( class generic -- )
    update-call-sites [ changed-definition ] each ;

M: generic update-generic
    [ changed-call-sites ]
    [ remake-generic drop ]
    [ changed-conditionally drop ]
    2tri ;

M: sequence update-methods
    implementors [ update-generic ] with each ;

HOOK: recompile compiler-impl ( words -- alist )

HOOK: to-recompile compiler-impl ( -- words )

HOOK: process-forgotten-words compiler-impl ( words -- )

<PRIVATE

SYMBOL: pending-new-words
pending-new-words [ V{ } clone ] initialize

: update-code-heap ( alist update-existing? reset-pics? -- changed? )
    pick empty? not [ modify-code-heap ] dip ;

: invalidate-new-words ( -- )
    pending-new-words get-global [ clear-set ] each ;

: invalidate-other-new-words ( -- )
    pending-new-words get-global [
        dup new-words get eq? [ drop ] [ clear-set ] if
    ] each ;

PRIVATE>

: compile ( words -- )
    recompile t f update-code-heap [ invalidate-new-words ] when ;

: filter-word-defs ( defset -- words )
    members [ word? ] filter ;

! Non-optimizing compiler
M: f update-call-sites
    2drop { } ;

M: f to-recompile
    changed-definitions get filter-word-defs ;

M: f recompile
    [ def>> ] zip-with ;

M: f process-forgotten-words drop ;

: without-optimizer ( quot -- )
    [ f compiler-impl ] dip with-variable ; inline

: <definitions> ( -- pair ) { HS{ } HS{ } } [ clone ] map ;

SYMBOL: definition-observers

GENERIC: definitions-changed ( set obj -- )

STARTUP-HOOK: [
    V{ } clone pending-new-words set-global
    V{ } clone definition-observers set-global

    ! This goes here because vocabs cannot depend on init
    V{ } clone vocab-observers set-global
]

: add-definition-observer ( obj -- )
    definition-observers get push ;

: remove-definition-observer ( obj -- )
    definition-observers get remove-eq! drop ;

: notify-definition-observers ( set -- )
    definition-observers get
    [ definitions-changed ] with each ;

! Incremented each time stack effects potentially changed, used
! by compiler.tree.propagation.call-effect for call( and execute(
! inline caching
: effect-counter ( -- n ) REDEFINITION-COUNTER special-object ; inline

GENERIC: always-bump-effect-counter? ( defspec -- ? )

M: object always-bump-effect-counter? drop f ;

<PRIVATE

: changed-vocabs ( set -- vocabs )
    filter-word-defs [ vocabulary>> dup [ lookup-vocab ] when ] map ;

: updated-definitions ( -- set )
    HS{ } clone
    forgotten-definitions get union!
    new-definitions get first union!
    new-definitions get second union!
    changed-definitions get union!
    maybe-changed get union!
    dup changed-vocabs over adjoin-all ;

: process-forgotten-definitions ( forgotten-definitions -- )
    members
    [ [ word? ] filter process-forgotten-words ]
    [ [ delete-definition-errors ] each ]
    bi ;

: bump-effect-counter? ( -- ? )
    changed-effects get members
    maybe-changed get members
    changed-definitions get members
    [ always-bump-effect-counter? ] filter
    3array union-all new-words get [ in? not ] curry any? ;

: bump-effect-counter ( -- )
    bump-effect-counter? [
        REDEFINITION-COUNTER special-object 0 or
        1 + REDEFINITION-COUNTER set-special-object
    ] when ;

: notify-observers ( -- )
    updated-definitions notify-definition-observers
    notify-error-observers ;

: update-existing? ( defs -- ? )
    new-words get [ in? not ] curry any? ;

: reset-pics? ( -- ? )
    outdated-generics get null? not ;

: finish-compilation-unit ( -- )
    [ ] [
        remake-generics
        to-recompile [
            recompile
            outdated-tuples get update-tuples
            forgotten-definitions get process-forgotten-definitions
        ] keep update-existing? reset-pics? update-code-heap
        ! Newly installed code may call a word in any unfinished unit,
        ! even across dynamic namespaces or threads.
        [ invalidate-other-new-words ] when
        bump-effect-counter
        notify-observers
    ] if-bootstrapping ;

: with-pending-new-words ( quot -- )
    new-words get pending-new-words get-global push
    [ [ finish-compilation-unit ] finally ]
    [ new-words get pending-new-words get-global remove-eq! drop ]
    finally ; inline

PRIVATE>

: with-nested-compilation-unit ( quot -- )
    H{ } clone
    HS{ } clone changed-definitions pick set-at
    HS{ } clone maybe-changed pick set-at
    HS{ } clone changed-effects pick set-at
    HS{ } clone outdated-generics pick set-at
    H{ } clone outdated-tuples pick set-at
    HS{ } clone new-words pick set-at
    [ with-pending-new-words ] with-variables ; inline

: with-compilation-unit ( quot -- )
    H{ } clone
    <definitions> new-definitions pick set-at
    <definitions> old-definitions pick set-at
    HS{ } clone forgotten-definitions pick set-at [
        with-nested-compilation-unit
    ] with-variables ; inline
