! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors generic hashtables inference io kernel math
namespaces optimizer prettyprint sequences test threads words ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        "Compiling " write dup . flush
        dup specialized-def dataflow optimize generate
    ] [
        drop
    ] if ;

: compile ( word -- )
    [ (compile) ] with-compiler ;

: compiled ( -- ) "compile" get [ word compile ] when ; parsing

: try-compile ( word -- )
    [ compile ] [ error. update-xt ] recover ;

: compile-vocabs ( vocabs -- )
    [ words ] map concat
    dup [ f "no-effect" set-word-prop ] each
    [ try-compile ] each ;

: compile-all ( -- ) vocabs compile-vocabs ;

: compile-quot ( quot -- word )
    define-temp "compile" get [ dup compile ] when ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    [
        recompile-words get hash-keys [ try-compile ] each
        recompile-words get clear-hash
    ] with-class<cache ;

M: compound unxref-word*
    dup "infer" word-prop [
        drop
    ] [
        dup dup recompile-words get set-hash
        { "infer-effect" "base-case" "no-effect" } reset-props
    ] if ;
