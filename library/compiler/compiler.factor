! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors generic hashtables inference io kernel math
namespaces optimizer parser prettyprint sequences test threads
words ;

SYMBOL: print-warnings

t print-warnings set-global

SYMBOL: batch-errors

GENERIC: batch-begins ( batch-errors -- )

M: f batch-begins drop ;

GENERIC: compile-begins ( word batch-errors -- )

M: f compile-begins drop "Compiling " write . flush ;

GENERIC: compile-error ( error batch-errors -- )

M: f compile-error
    drop
    dup inference-error-major? print-warnings get or
    [ dup error. flush ] when drop ;

GENERIC: batch-ends ( batch-errors -- )

M: f batch-ends drop ;

: word-dataflow ( word -- dataflow )
    [
        dup ?no-effect
        dup dup add-recursive-state
        dup specialized-def (dataflow)
        swap current-effect check-effect
    ] with-infer ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        dup batch-errors get compile-begins
        dup word-dataflow optimize generate
    ] [
        drop
    ] if ;

: compile ( word -- )
    [ (compile) ] with-compiler ;

: try-compile ( word -- )
    [
        compile
    ] [
        batch-errors get compile-error update-xt
    ] recover ;

: compile-batch ( seq -- )
    batch-errors get batch-begins
    dup
    [ f "no-effect" set-word-prop ] each
    [ try-compile ] each
    batch-errors get batch-ends ;

: compile-vocabs ( seq -- )
    [ words ] map concat compile-batch ;

: compile-all ( -- )
    vocabs compile-vocabs changed-words get clear-hash ;

: compile-quot ( quot -- word )
    define-temp "compile" get [ dup compile ] when ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    changed-words get [
        dup hash-keys compile-batch clear-hash
    ] when* ;

[ recompile ] parse-hook set
