! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors generic hashtables inference io kernel math
namespaces optimizer parser prettyprint sequences test threads
words ;

: word-dataflow ( word -- dataflow )
    [
        dup ?no-effect
        dup dup add-recursive-state
        dup specialized-def (dataflow)
        swap current-effect check-effect
    ] with-infer ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        "Compiling " write dup . flush
        dup word-dataflow optimize generate
    ] [
        drop
    ] if ;

: compile ( word -- )
    [ (compile) ] with-compiler ;

: try-compile ( word -- )
    [ compile ] [ error. update-xt ] recover ;

: compile-vocabs ( seq -- )
    [ words ] map concat
    dup [ f "no-effect" set-word-prop ] each
    [ try-compile ] each ;

: compile-all ( -- )
    vocabs compile-vocabs changed-words get clear-hash ;

: compile-quot ( quot -- word )
    define-temp "compile" get [ dup compile ] when ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    changed-words get [
        dup hash-keys [ try-compile ] each clear-hash
    ] when* ;

[ recompile ] parse-hook set
