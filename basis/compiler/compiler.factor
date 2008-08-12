! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io debugger words
compiler.units continuations vocabs assocs dlists definitions
math threads graphs generic combinators dequeues search-dequeues
stack-checker stack-checker.state compiler.generator
compiler.errors compiler.tree.builder compiler.tree.optimizer ;
IN: compiler

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

: compile-begins ( word -- )
    f swap compiler-error ;

: compile-failed ( word error -- )
    [ swap compiler-error ]
    [
        drop
        [ compiled-unxref ]
        [ f swap compiled get set-at ]
        [ +failed+ save-effect ]
        tri
    ] 2bi ;

: compile-succeeded ( effect word -- )
    [ swap save-effect ]
    [ compiled-unxref ]
    [
        dup crossref?
        [ dependencies get compiled-xref ] [ drop ] if
    ] tri ;

: (compile) ( word -- )
    [
        H{ } clone dependencies set

        {
            [ compile-begins ]
            [
                [ build-tree-from-word ] [ compile-failed return ] recover
                optimize-tree
            ]
            [ dup generate ]
            [ compile-succeeded ]
        } cleave
    ] curry with-return ;

: compile-loop ( dequeue -- )
    [ (compile) yield ] slurp-dequeue ;

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
