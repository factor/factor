! Copyright (C) 2004, 2005 Slava Pestov.
IN: compiler
USING: errors inference kernel lists namespaces prettyprint
stdio words ;

: supported-cpu? ( -- ? )
    cpu "unknown" = not ;

: check-architecture ( -- )
    supported-cpu? [
        "Unsupported CPU; compiler disabled" throw
    ] unless ;

: compiling ( word -- word parameter )
    check-architecture
    "Compiling " write dup . flush
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
    "Cannot compile " write swap . print-error ;

: try-compile ( word -- )
    [ compile ] [ [ cannot-compile ] when* ] catch ;

: compile-all ( -- )
    #! Compile all words.
    supported-cpu? [
        [ try-compile ] each-word
    ] [
        "Unsupported CPU" print
    ] ifte ;

: decompile ( word -- )
    [ word-primitive ] keep set-word-primitive ;

: recompile ( word -- )
    dup decompile compile ;
