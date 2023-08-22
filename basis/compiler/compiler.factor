! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.algebra combinators
combinators.short-circuit compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien compiler.cfg.finalization
compiler.cfg.optimizer compiler.codegen compiler.crossref
compiler.errors compiler.tree.builder compiler.tree.optimizer
compiler.units compiler.utilities continuations definitions
generic generic.single io kernel macros make namespaces
sequences sets stack-checker.dependencies stack-checker.errors
stack-checker.inlining vocabs.loader words ;
IN: compiler

SYMBOL: compiled

: compile? ( word -- ? )
    ! Don't attempt to compile certain words.
    {
        [ "forgotten" word-prop ]
        [ inlined-block? ]
    } 1|| not ;

: compiler-message ( string -- )
    "trace-compilation" get [ [ print flush ] with-global ] [ drop ] if ;

: start-compilation ( word -- )
    dup name>> compiler-message
    H{ } clone dependencies namespaces:set
    H{ } clone generic-dependencies namespaces:set
    HS{ } clone conditional-dependencies namespaces:set
    clear-compiler-error ;

GENERIC: no-compile? ( word -- ? )

M: method no-compile? "method-generic" word-prop no-compile? ;

M: predicate-engine-word no-compile? "owner-generic" word-prop no-compile? ;

M: word no-compile?
    { [ macro? ] [ "special" word-prop ] [ "no-compile" word-prop ] } 1|| ;

GENERIC: combinator? ( word -- ? )

M: method combinator? "method-generic" word-prop combinator? ;

M: predicate-engine-word combinator? "owner-generic" word-prop combinator? ;

M: word combinator? inline? ;

: ignore-error? ( word error -- ? )
    ! Ignore some errors on inline combinators, macros, and special
    ! words such as 'call'.
    {
        [ drop no-compile? ]
        [ [ combinator? ] [ unknown-macro-input? ] bi* and ]
    } 2|| ;

: finish-compilation ( word -- )
    ! Recompile callers if the word's stack effect changed, then
    ! save the word's dependencies so that if they change, the
    ! word can get recompiled too.
    [ compiled-unxref ]
    [
        dup crossref? [
            [ dependencies get generic-dependencies get compiled-xref ]
            [ conditional-dependencies get set-dependency-checks ]
            bi
        ] [ drop ] if
    ] bi ;

: deoptimize-with ( word def -- * )
    ! If the word failed to infer, compile it with the
    ! non-optimizing compiler.
    swap [ finish-compilation ] [ compiled get set-at ] bi return ;

: not-compiled-def ( word error -- def )
    '[ _ _ not-compiled ] [ ] like ;

: deoptimize* ( word -- * )
    dup def>> deoptimize-with ;

: ignore-error ( word error -- * )
    drop [ clear-compiler-error ] [ deoptimize* ] bi ;

: remember-error ( word error -- * )
    [ swap <compiler-error> save-compiler-error ]
    [ [ drop ] [ not-compiled-def ] 2bi deoptimize-with ]
    2bi ;

: deoptimize ( word error -- * )
    ! If the error is ignorable, compile the word with the
    ! non-optimizing compiler, using its definition. Otherwise,
    ! if the compiler error is not ignorable, use a dummy
    ! definition from 'not-compiled-def' which throws an error.
    {
        { [ dup inference-error? not ] [ rethrow ] }
        { [ 2dup ignore-error? ] [ ignore-error ] }
        [ remember-error ]
    } cond ;

: optimize? ( word -- ? )
    {
        [ single-generic? ]
        [ primitive? ]
    } 1|| not ;

: contains-breakpoints? ( -- ? )
    dependencies get keys [ "break?" word-prop ] any? ;

: frontend ( word -- tree )
    ! If the word contains breakpoints, don't optimize it, since
    ! the walker does not support this.
    dup optimize? [
        [ [ build-tree ] [ deoptimize ] recover optimize-tree ] keep
        contains-breakpoints? [ nip deoptimize* ] [ drop ] if
    ] [ deoptimize* ] if ;

: backend ( tree word -- )
    build-cfg [
        [
            [ optimize-cfg ]
            [ finalize-cfg ]
            [ [ generate ] [ label>> ] bi compiled get set-at ]
            tri
        ] with-cfg
    ] each ;

: compile-word ( word -- )
    ! We return early if the word has breakpoints or if it
    ! failed to infer.
    '[
        _ {
            [ start-compilation ]
            [ frontend ]
            [ backend ]
            [ finish-compilation ]
        } cleave
    ] with-return ;

SINGLETON: optimizing-compiler

M: optimizing-compiler update-call-sites ( class generic -- words )
    ! Words containing call sites with inferred type 'class'
    ! which inlined a method on 'generic'
    generic-call-sites-of keys swap '[
        _ 2dup [ classoid? ] both?
        [ classes-intersect? ] [ 2drop f ] if
    ] filter ;

M: optimizing-compiler recompile ( words -- alist )
    H{ } clone compiled [
        [ compile? ] filter
        [ compile-word yield-hook get call( -- ) ] each
        compiled get >alist
    ] with-variable
    "--- compile done" compiler-message ;

M: optimizing-compiler to-recompile ( -- words )
    [
        changed-effects get new-words get diff
        outdated-effect-usages %

        changed-definitions get new-words get diff
        outdated-definition-usages %

        maybe-changed get new-words get diff
        outdated-conditional-usages %

        changed-definitions get filter-word-defs dup zip ,
    ] { } make assoc-union-all keys ;

M: optimizing-compiler process-forgotten-words
    [ delete-compiled-xref ] each ;

: enable-optimizer ( -- )
    optimizing-compiler compiler-impl set-global ;

: disable-optimizer ( -- )
    f compiler-impl set-global ;

{ "prettyprint" "compiler" } "compiler.prettyprint" require-when
{ "threads" "compiler" } "compiler.threads" require-when
