! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces arrays sequences io
words fry continuations vocabs assocs dlists definitions math
graphs generic combinators deques search-deques io
stack-checker stack-checker.state stack-checker.inlining
compiler.errors compiler.units compiler.tree.builder
compiler.tree.optimizer compiler.cfg.builder
compiler.cfg.optimizer compiler.cfg.linearization
compiler.cfg.two-operand compiler.cfg.linear-scan
compiler.cfg.stack-frame compiler.codegen compiler.utilities ;
IN: compiler

SYMBOL: compile-queue
SYMBOL: compiled

: queue-compile ( word -- )
    {
        { [ dup "forgotten" word-prop ] [ ] }
        { [ dup compiled get key? ] [ ] }
        { [ dup inlined-block? ] [ ] }
        { [ dup primitive? ] [ ] }
        [ dup compile-queue get push-front ]
    } cond drop ;

: maybe-compile ( word -- )
    dup optimized>> [ drop ] [ queue-compile ] if ;

SYMBOL: +failed+

: ripple-up ( words -- )
    dup "compiled-effect" word-prop +failed+ eq?
    [ usage [ word? ] filter ] [ compiled-usage keys ] if
    [ queue-compile ] each ;

: ripple-up? ( word effect -- ? )
    #! If the word has previously been compiled and had a
    #! different stack effect, we have to recompile any callers.
    swap "compiled-effect" word-prop [ = not ] keep and ;

: save-effect ( word effect -- )
    [ dupd ripple-up? [ ripple-up ] [ drop ] if ]
    [ "compiled-effect" set-word-prop ]
    2bi ;

: start ( word -- )
    "trace-compilation" get [ dup name>> print flush ] when
    H{ } clone dependencies set
    H{ } clone generic-dependencies set
    f swap compiler-error ;

: fail ( word error -- )
    [ swap compiler-error ]
    [
        drop
        [ compiled-unxref ]
        [ f swap compiled get set-at ]
        [ +failed+ save-effect ]
        tri
    ] 2bi
    return ;

: frontend ( word -- effect nodes )
    [ build-tree-from-word ] [ fail ] recover optimize-tree ;

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

: finish ( effect word -- )
    [ swap save-effect ]
    [ compiled-unxref ]
    [
        dup crossref?
        [
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
    [ (compile) yield-hook get call ] slurp-deque ;

: decompile ( word -- )
    f 2array 1array t modify-code-heap ;

: optimized-recompile-hook ( words -- alist )
    [
        <hashed-dlist> compile-queue set
        H{ } clone compiled set
        [ queue-compile ] each
        compile-queue get compile-loop
        compiled get >alist
    ] with-scope ;

: enable-compiler ( -- )
    [ optimized-recompile-hook ] recompile-hook set-global ;

: disable-compiler ( -- )
    [ default-recompile-hook ] recompile-hook set-global ;

: recompile-all ( -- )
    forget-errors all-words compile ;
