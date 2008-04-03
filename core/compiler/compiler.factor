! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
inference.state generator debugger math.parser prettyprint words
compiler.units continuations vocabs assocs alien.compiler dlists
optimizer definitions math compiler.errors threads graphs
generic inference ;
IN: compiler

: ripple-up ( word -- )
    compiled-usage [ drop queue-compile ] assoc-each ;

: save-effect ( word effect -- )
    over "compiled-uses" word-prop [
        2dup swap "compiled-effect" word-prop =
        [ over ripple-up ] unless
    ] when
    "compiled-effect" set-word-prop ;

: finish-compile ( word effect dependencies -- )
    >r dupd save-effect r>
    over compiled-unxref
    over crossref? [ compiled-xref ] [ 2drop ] if ;

: compile-succeeded ( word -- effect dependencies )
    [
        [ word-dataflow optimize ] keep dup generate
    ] computing-dependencies ;

: compile-failed ( word error -- )
    f pick compiled get set-at
    swap compiler-error ;

: (compile) ( word -- )
    f over compiler-error
    [ dup compile-succeeded finish-compile ]
    [ dupd compile-failed f save-effect ]
    recover ;

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
