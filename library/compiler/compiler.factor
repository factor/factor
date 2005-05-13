! Copyright (C) 2004, 2005 Slava Pestov.
IN: compiler
USING: compiler-backend compiler-frontend errors inference
kernel lists namespaces prettyprint stdio words ;

: supported-cpu? ( -- ? )
    cpu "unknown" = not ;

: check-architecture ( -- )
    supported-cpu? [
        "Unsupported CPU; compiler disabled" throw
    ] unless ;

: compiling ( word -- word parameter )
    check-architecture
    "Compiling " write dup word. terpri flush
    dup word-def ;

GENERIC: (compile) ( word -- )

M: word (compile) drop ;

M: compound (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    compiling dataflow optimize linearize simplify generate ;

: precompile ( word -- )
    #! Print linear IR of word.
    [
        word-def dataflow optimize linearize simplify [.]
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
    "Cannot compile " write swap word. terpri print-error ;

: try-compile ( word -- )
    [ compile ] [ [ cannot-compile ] when* ] catch ;

: compile-all ( -- ) [ try-compile ] each-word ;

: decompile ( word -- )
    dup compiled? [
        "Decompiling " write dup word. terpri flush
        [ word-primitive ] keep set-word-primitive
    ] [
        drop
    ] ifte ;

M: compound (uncrossref)
    dup f "infer-effect" set-word-prop
    dup f "no-effect" set-word-prop
    decompile ;

: recompile ( word -- )
    dup decompile compile ;
