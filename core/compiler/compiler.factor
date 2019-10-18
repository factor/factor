! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors generic hashtables inference io kernel math
namespaces generator optimizer parser prettyprint sequences
threads words ;

SYMBOL: print-warnings

t print-warnings set-global

SYMBOL: batch-errors

GENERIC: batch-begins ( batch-errors -- )

GENERIC: compile-begins ( word batch-errors -- )

GENERIC: compile-error ( error batch-errors -- )

GENERIC: batch-ends ( batch-errors -- )

M: f batch-begins drop ;

M: f compile-begins
    drop
    "quiet" get [ drop ] [ "Compiling " write . flush ] if ;

M: f compile-error
    drop
    dup inference-error-major?
    print-warnings get or
    "quiet" get not and
    [ error. flush ] [ drop ] if ;

M: f batch-ends drop ;

: word-dataflow ( word -- dataflow )
    [
        dup "no-effect" word-prop [ no-effect ] when
        dup dup add-recursive-state
        [ specialized-def (dataflow) ] keep
        finish-word 2drop
    ] with-infer ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        dup batch-errors get compile-begins
        dup dup word-dataflow optimize generate
    ] [
        drop
    ] if ;

: compile ( word -- )
    [ (compile) ] with-compiler ;

: compile-failed ( word error -- )
    batch-errors get compile-error
    dup update-xt unchanged-word ;

: try-compile ( word -- )
    [ compile ] [ compile-failed ] recover ;

: with-batch ( quot -- )
    batch-errors get dup batch-begins slip batch-ends ; inline

: forget-errors ( seq -- )
    [ f "no-effect" set-word-prop ] each ;

: compiling-batch ( n -- )
    "Compiling " write length pprint " words..." print flush ;

: compile-batch ( seq -- )
    dup empty? [
        drop
    ] [
        dup compiling-batch
        [ dup forget-errors [ try-compile ] each ] with-batch
    ] if ;

: compile-vocabs ( seq -- )
    [ words ] map concat compile-batch ;

: compile-all ( -- ) vocabs compile-vocabs ;

: compile-quot ( quot -- word )
    define-temp dup compile ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    changed-words get [
        dup hash-keys compile-batch clear-hash
    ] when* ;
