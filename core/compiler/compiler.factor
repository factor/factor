! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
inference.state generator debugger words compiler.units
continuations vocabs assocs alien.compiler dlists optimizer
definitions math compiler.errors threads graphs generic
inference combinators ;
IN: compiler

: ripple-up ( word -- )
    compiled-usage [ drop queue-compile ] assoc-each ;

: save-effect ( word effect -- )
    [
        over "compiled-effect" word-prop = [
            dup "compiled-uses" word-prop
            [ dup ripple-up ] when
        ] unless drop
    ]
    [ "compiled-effect" set-word-prop ] 2bi ;

: compile-begins ( word -- )
    f swap compiler-error ;

: compile-failed ( word error -- )
    [ swap compiler-error ]
    [
        drop
        [ f swap compiled get set-at ]
        [ f save-effect ]
        bi
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
                [ word-dataflow ] [ compile-failed return ] recover
                optimize
            ]
            [ dup generate ]
            [ compile-succeeded ]
        } cleave
    ] curry with-return ;

: compile-loop ( assoc -- )
    dup assoc-empty? [ drop ] [
        dup delete-any drop (compile)
        yield
        compile-loop
    ] if ;

: decompile ( word -- )
    f 2array 1array t modify-code-heap ;

: optimized-recompile-hook ( words -- alist )
    [
        H{ } clone compile-queue set
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
