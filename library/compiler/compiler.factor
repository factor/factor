! Copyright (C) 2004, 2005 Slava Pestov.
IN: compiler
USING: compiler-backend compiler-frontend errors inference io
kernel lists math namespaces optimizer prettyprint sequences
words ;

: supported-cpu? ( -- ? )
    cpu "unknown" = not ;

: precompile ( quotation -- basic-blocks )
    dataflow optimize linearize split-blocks simplify ;

: (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    "Compiling " write dup . dup word-def precompile generate ;

: compile-postponed ( -- )
    compile-words get dup empty?
    [ dup pop (compile) compile-postponed ] unless drop ;

: compile ( word -- )
    [ postpone-word compile-postponed ] with-compiler ;

: compiled ( -- )
    #! Compile the most recently defined word.
    "compile" get [ word compile ] when ; parsing

: try-compile ( word -- )
    [ compile ] [ [ error. drop ] when* ] catch ;

: compile-all ( -- ) [ try-compile ] each-word ;

: recompile ( word -- ) dup update-xt compile ;

: compile-1 ( quot -- )
    #! Compute and call a quotation.
    "compile" get [
        gensym [ swap define-compound ] keep dup compile execute
    ] [
        call
    ] ifte ;

\ dataflow profile
\ optimize profile
\ linearize profile
\ split-blocks profile
\ simplify profile
\ keep-optimizing profile
\ literals profile
\ kill-set profile
\ kill-node profile
\ infer-classes profile
\ solve-recursion profile
\ split-node profile
