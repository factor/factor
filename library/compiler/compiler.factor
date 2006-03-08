! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: compiler-backend compiler-frontend errors hashtables
inference io kernel lists math namespaces optimizer prettyprint
sequences words ;

: (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    dup word-def dataflow optimize linearize
    [ split-blocks simplify generate ] hash-each ;

: inform-compile ( word -- ) "Compiling " write . flush ;

: compile-postponed ( -- )
    compile-words get dup empty? [
        dup pop
        dup inform-compile
        (compile)
        compile-postponed
    ] unless drop ;

: compile ( word -- )
    [ postpone-word compile-postponed ] with-compiler ;

: compiled ( -- )
    #! Compile the most recently defined word.
    "compile" get [ word compile ] when ; parsing

: try-compile ( word -- )
    [ compile ] [ error. drop ] recover ;

: compile-vocabs ( vocabs -- )
    [ words ] map concat
    dup [ f "no-effect" set-word-prop ] each
    [ try-compile ] each ;

: compile-all ( -- ) vocabs compile-vocabs ;

: recompile ( word -- ) dup update-xt compile ;

: compile-1 ( quot -- )
    #! Compute and call a quotation.
    "compile" get [
        gensym [ swap define-compound ] keep dup compile execute
    ] [
        call
    ] if ;
