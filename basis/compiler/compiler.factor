! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces arrays sequences io words fry
continuations vocabs assocs dlists definitions math graphs generic
generic.single combinators deques search-deques macros
source-files.errors combinators.short-circuit

stack-checker stack-checker.dependencies stack-checker.inlining
stack-checker.errors

compiler.errors compiler.units compiler.utilities

compiler.tree.builder
compiler.tree.optimizer

compiler.crossref

compiler.cfg
compiler.cfg.builder
compiler.cfg.optimizer
compiler.cfg.mr

compiler.codegen ;
IN: compiler

SYMBOL: compile-queue
SYMBOL: compiled

: compile? ( word -- ? )
    #! Don't attempt to compile certain words.
    {
        [ "forgotten" word-prop ]
        [ compiled get key? ]
        [ inlined-block? ]
    } 1|| not ;

: queue-compile ( word -- )
    dup compile? [ compile-queue get push-front ] [ drop ] if ;

: recompile-callers? ( word -- ? )
    changed-effects get key? ;

: recompile-callers ( words -- )
    #! If a word's stack effect changed, recompile all words that
    #! have compiled calls to it.
    dup recompile-callers?
    [ compiled-usage keys [ queue-compile ] each ] [ drop ] if ;

: compiler-message ( string -- )
    "trace-compilation" get [ global [ print flush ] bind ] [ drop ] if ;

: start ( word -- )
    dup name>> compiler-message
    H{ } clone dependencies set
    H{ } clone generic-dependencies set
    clear-compiler-error ;

GENERIC: no-compile? ( word -- ? )

M: method-body no-compile? "method-generic" word-prop no-compile? ;

M: predicate-engine-word no-compile? "owner-generic" word-prop no-compile? ;

M: word no-compile?
    { [ macro? ] [ "special" word-prop ] [ "no-compile" word-prop ] } 1|| ;

GENERIC: combinator? ( word -- ? )

M: method-body combinator? "method-generic" word-prop combinator? ;

M: predicate-engine-word combinator? "owner-generic" word-prop combinator? ;

M: word combinator? inline? ;

: ignore-error? ( word error -- ? )
    #! Ignore some errors on inline combinators, macros, and special
    #! words such as 'call'.
    {
        [ drop no-compile? ]
        [ [ combinator? ] [ unknown-macro-input? ] bi* and ]
    } 2|| ;

: finish ( word -- )
    #! Recompile callers if the word's stack effect changed, then
    #! save the word's dependencies so that if they change, the
    #! word can get recompiled too.
    [ recompile-callers ]
    [ compiled-unxref ]
    [
        dup crossref? [
            dependencies get
            generic-dependencies get
            compiled-xref
        ] [ drop ] if
    ] tri ;

: deoptimize-with ( word def -- * )
    #! If the word failed to infer, compile it with the
    #! non-optimizing compiler. 
    swap [ finish ] [ compiled get set-at ] bi return ;

: not-compiled-def ( word error -- def )
    '[ _ _ not-compiled ] [ ] like ;

: deoptimize* ( word -- * )
    dup def>> deoptimize-with ;

: ignore-error ( word error -- * )
    drop [ clear-compiler-error ] [ deoptimize* ] bi ;

: remember-error ( word error -- * )
    [ swap <compiler-error> compiler-error ]
    [ [ drop ] [ not-compiled-def ] 2bi deoptimize-with ]
    2bi ;

: deoptimize ( word error -- * )
    #! If the error is ignorable, compile the word with the
    #! non-optimizing compiler, using its definition. Otherwise,
    #! if the compiler error is not ignorable, use a dummy
    #! definition from 'not-compiled-def' which throws an error.
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
    #! If the word contains breakpoints, don't optimize it, since
    #! the walker does not support this.
    dup optimize? [
        [ [ build-tree ] [ deoptimize ] recover optimize-tree ] keep
        contains-breakpoints? [ nip deoptimize* ] [ drop ] if
    ] [ deoptimize* ] if ;

: compile-dependency ( word -- )
    #! If a word calls an unoptimized word, try to compile the callee.
    dup optimized? [ drop ] [ queue-compile ] if ;

! Only switch this off for debugging.
SYMBOL: compile-dependencies?

t compile-dependencies? set-global

: compile-dependencies ( asm -- )
    compile-dependencies? get
    [ calls>> [ compile-dependency ] each ] [ drop ] if ;

: save-asm ( asm -- )
    [ [ code>> ] [ label>> ] bi compiled get set-at ]
    [ compile-dependencies ]
    bi ;

: backend ( tree word -- )
    build-cfg [
        [ optimize-cfg build-mr ] with-cfg
        generate
        save-asm
    ] each ;

: compile-word ( word -- )
    #! We return early if the word has breakpoints or if it
    #! failed to infer.
    '[
        _ {
            [ start ]
            [ frontend ]
            [ backend ]
            [ finish ]
        } cleave
    ] with-return ;

: compile-loop ( deque -- )
    [ compile-word yield-hook get call( -- ) ] slurp-deque ;

: decompile ( word -- )
    dup def>> 2array 1array modify-code-heap ;

: compile-call ( quot -- )
    [ dup infer define-temp ] with-compilation-unit execute ;

\ compile-call t "no-compile" set-word-prop

SINGLETON: optimizing-compiler

M: optimizing-compiler recompile ( words -- alist )
    [
        <hashed-dlist> compile-queue set
        H{ } clone compiled set
        [
            [ queue-compile ]
            [ subwords [ compile-dependency ] each ] bi
        ] each
        compile-queue get compile-loop
        compiled get >alist
    ] with-scope
    "--- compile done" compiler-message ;

M: optimizing-compiler to-recompile ( -- words )
    changed-definitions get compiled-usages
    changed-generics get compiled-generic-usages
    append assoc-combine keys ;

M: optimizing-compiler process-forgotten-words
    [ delete-compiled-xref ] each ;

: with-optimizer ( quot -- )
    [ optimizing-compiler compiler-impl ] dip with-variable ; inline

: enable-optimizer ( -- )
    optimizing-compiler compiler-impl set-global ;

: disable-optimizer ( -- )
    f compiler-impl set-global ;

: recompile-all ( -- )
    all-words compile ;
