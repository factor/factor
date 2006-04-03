! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors hashtables inference io kernel lists math
namespaces optimizer prettyprint sequences test words ;

: (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    dup word-def dataflow optimize linearize
    [ generate ] hash-each ;

: benchmark-compile
    [ [ (compile) ] keep ] benchmark nip
    "compile-time" set-word-prop ;

: inform-compile ( word -- ) "Compiling " write . flush ;

: compile-postponed ( -- )
    compile-words get dup empty? [
        dup pop
        dup inform-compile
        benchmark-compile
        compile-postponed
    ] unless drop ;

: compile ( word -- )
    [ postpone-word compile-postponed ] with-compiler ;

: compiled ( -- ) "compile" get [ word compile ] when ; parsing

: try-compile ( word -- )
    [ compile ] [ error. drop ] recover ;

: compile-vocabs ( vocabs -- )
    [ words ] map concat
    dup [ f "no-effect" set-word-prop ] each
    [ try-compile ] each ;

: compile-all ( -- ) vocabs compile-vocabs ;

: recompile ( word -- ) dup update-xt compile ;

: compile-quot ( quot -- word )
    gensym [ swap define-compound ] keep
    "compile" get [ dup compile ] when ;

: compile-1 ( quot -- ) compile-quot execute ;
