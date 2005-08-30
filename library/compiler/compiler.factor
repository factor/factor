! Copyright (C) 2004, 2005 Slava Pestov.
IN: compiler
USING: compiler-backend compiler-frontend errors inference io
kernel lists math namespaces prettyprint sequences words ;

: supported-cpu? ( -- ? )
    cpu "unknown" = not ;

: check-architecture ( -- )
    supported-cpu? [
        "Unsupported CPU; compiler disabled" throw
    ] unless ;

: compiling ( word -- word parameter )
    check-architecture "Compiling " write dup . dup word-def ;

GENERIC: (compile) ( word -- )

M: word (compile) drop ;

M: compound (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    compiling dataflow optimize linearize simplify generate ;

: precompile ( word -- )
    #! Print linear IR of word.
    [
        word-def dataflow optimize linearize simplify [ . ] each
    ] with-scope ;

: compile-postponed ( -- )
    compile-words get [
        uncons compile-words set (compile) compile-postponed
    ] when* ;

: compile ( word -- )
    [ postpone-word compile-postponed ] with-compiler ;

: compiled ( -- )
    #! Compile the most recently defined word.
    "compile" get [ word compile ] when ; parsing

: cannot-compile ( word error -- )
    "Cannot compile " write swap . print-error ;

: try-compile ( word -- )
    [ compile ] [ [ cannot-compile ] when* ] catch ;

: compile-all ( -- ) [ try-compile ] each-word ;

: decompile ( word -- )
    dup compiled? [
        "Decompiling " write dup . update-xt
    ] [
        drop
    ] ifte ;

: recompile ( word -- )
    dup decompile compile ;

: compile-1 ( quot -- word )
    #! Compute a quotation into an uninterned word, for testing
    #! purposes.
    gensym [ swap define-compound ] keep dup compile execute ;

\ dataflow profile
\ optimize profile
\ linearize profile
\ simplify profile
\ generate profile
\ kill-node profile
\ partial-eval profile
\ inline-method profile
\ apply-identities profile
\ subst-values profile
\ split-branch profile
