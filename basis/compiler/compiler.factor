! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces arrays sequences io words fry
continuations vocabs assocs dlists definitions math graphs generic
combinators deques search-deques macros io source-files.errors stack-checker
stack-checker.state stack-checker.inlining combinators.short-circuit
compiler.errors compiler.units compiler.tree.builder
compiler.tree.optimizer compiler.cfg.builder compiler.cfg.optimizer
compiler.cfg.linearization compiler.cfg.two-operand
compiler.cfg.linear-scan compiler.cfg.stack-frame compiler.codegen
compiler.utilities ;
IN: compiler

SYMBOL: compile-queue
SYMBOL: compiled

: queue-compile? ( word -- ? )
    {
        [ "forgotten" word-prop ]
        [ compiled get key? ]
        [ inlined-block? ]
        [ primitive? ]
    } 1|| not ;

: queue-compile ( word -- )
    dup queue-compile? [ compile-queue get push-front ] [ drop ] if ;

: maybe-compile ( word -- )
    dup optimized>> [ drop ] [ queue-compile ] if ;

: recompile-callers? ( word -- ? )
    changed-effects get key? ;

: recompile-callers ( words -- )
    dup recompile-callers? [
        [ usage [ word? ] filter ] [ compiled-usage keys ] bi
        [ [ queue-compile ] each ] bi@
    ] [ drop ] if ;

: start ( word -- )
    "trace-compilation" get [ dup name>> print flush ] when
    H{ } clone dependencies set
    H{ } clone generic-dependencies set
    f swap compiler-error ;

: ignore-error? ( word error -- ? )
    [
        {
            [ macro? ]
            [ inline? ]
            [ "special" word-prop ]
            [ "no-compile" word-prop ]
        } 1||
    ] [ error-type +compiler-warning+ eq? ] bi* and ;

: (fail) ( word compiled -- * )
    swap
    [ recompile-callers ]
    [ compiled-unxref ]
    [ compiled get set-at ]
    tri return ;

: not-compiled-def ( word error -- def )
    '[ _ _ not-compiled ] [ ] like ;

: fail ( word error -- * )
    2dup ignore-error?
    [ drop f over def>> ]
    [ 2dup not-compiled-def ] if
    [ swap compiler-error ] [ (fail) ] bi-curry* bi ;

: frontend ( word -- nodes )
    dup contains-breakpoints? [ dup def>> (fail) ] [
        [ build-tree-from-word ] [ fail ] recover optimize-tree
    ] if ;

! Only switch this off for debugging.
SYMBOL: compile-dependencies?

t compile-dependencies? set-global

: save-asm ( asm -- )
    [ [ code>> ] [ label>> ] bi compiled get set-at ]
    [ compile-dependencies? get [ calls>> [ maybe-compile ] each ] [ drop ] if ]
    bi ;

: backend ( nodes word -- )
    build-cfg [
        optimize-cfg
        build-mr
        convert-two-operand
        linear-scan
        build-stack-frame
        generate
        save-asm
    ] each ;

: finish ( word -- )
    [ recompile-callers ]
    [ compiled-unxref ]
    [
        dup crossref? [
            dependencies get
            generic-dependencies get
            compiled-xref
        ] [ drop ] if
    ] tri ;

: (compile) ( word -- )
    '[
        _ {
            [ start ]
            [ frontend ]
            [ backend ]
            [ finish ]
        } cleave
    ] with-return ;

: compile-loop ( deque -- )
    [ (compile) yield-hook get call( -- ) ] slurp-deque ;

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
        [ queue-compile ] each
        compile-queue get compile-loop
        compiled get >alist
    ] with-scope ;

: enable-compiler ( -- )
    optimizing-compiler compiler-impl set-global ;

: disable-compiler ( -- )
    f compiler-impl set-global ;

: recompile-all ( -- )
    all-words compile ;
