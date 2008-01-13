! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
inference.state generator debugger math.parser prettyprint words
compiler.units continuations vocabs assocs alien.compiler dlists
optimizer definitions math compiler.errors threads graphs
generic ;
IN: compiler

SYMBOL: compiled-crossref

compiled-crossref global [ H{ } assoc-like ] change-at

: compiled-xref ( word dependencies -- )
    2dup "compiled-uses" set-word-prop
    compiled-crossref get add-vertex* ;

: compiled-unxref ( word -- )
    dup "compiled-uses" word-prop
    compiled-crossref get remove-vertex* ;

: compiled-usage ( word -- assoc )
    compiled-crossref get at ;

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
    f pick compiler-error
    over compiled-unxref
    compiled-xref ;

: compile-succeeded ( word -- effect dependencies )
    [
        dup word-dataflow >r swap dup r> optimize generate
    ] computing-dependencies ;

: compile-failed ( word error -- )
    f pick compiled get set-at
    swap compiler-error ;

: (compile) ( word -- )
    [ dup compile-succeeded finish-compile ]
    [ dupd compile-failed f save-effect ]
    recover ;

: delete-any ( assoc -- element )
    [ [ 2drop t ] assoc-find 2drop dup ] keep delete-at ;

: compile-loop ( assoc -- )
    dup assoc-empty? [ drop ] [
        dup delete-any (compile)
        yield
        compile-loop
    ] if ;

: recompile ( words -- )
    [
        H{ } clone compile-queue set
        H{ } clone compiled set
        [ queue-compile ] each
        compile-queue get compile-loop
        compiled get >alist modify-code-heap
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
    f 2array 1array modify-code-heap ;
