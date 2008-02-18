! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
inference.state generator debugger math.parser prettyprint words
compiler.units continuations vocabs assocs alien.compiler dlists
optimizer definitions math compiler.errors concurrency.threads
graphs generic ;
IN: compiler

: compiled-usages ( words -- seq )
    [ [ dup ] H{ } map>assoc dup ] keep [
        compiled-usage [ nip +inlined+ eq? ] assoc-subset update
    ] with each keys ;

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

: recompile ( words -- )
    [
        H{ } clone compile-queue set
        H{ } clone compiled set
        [ queue-compile ] each
        compile-queue get compile-loop
        compiled get >alist
        dup [ drop crossref? ] assoc-contains?
        modify-code-heap
    ] with-scope ; inline

: compile ( words -- )
    [ compiled? not ] subset recompile ;

: compile-call ( quot -- )
    H{ } clone changed-words
    [ define-temp dup 1array compile ] with-variable
    execute ;

: recompile-all ( -- )
    [ all-words recompile ] with-compiler-errors ;

: decompile ( word -- )
    f 2array 1array t modify-code-heap ;
