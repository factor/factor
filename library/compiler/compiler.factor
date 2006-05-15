! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors hashtables inference io kernel math
namespaces optimizer prettyprint sequences test words ;

: (compile) ( word -- )
    dup specialized-def dataflow optimize generate ;

: inform-compile ( word -- ) "Compiling " write . flush ;

: compile-postponed ( -- )
    compile-words get dup empty? [
        drop
    ] [
        pop dup inform-compile (compile) compile-postponed
    ] if ;

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
