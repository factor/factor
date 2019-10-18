! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors generic assocs inference io kernel math
namespaces generator optimizer parser prettyprint sequences
threads words arrays ;

SYMBOL: compiler-hook

SYMBOL: compile-errors

SYMBOL: batch-mode

: compile-begins ( word -- )
    compiler-hook get call
    "quiet" get batch-mode get or [
        drop
    ] [
        "Compiling " write . flush
    ] if ;

M: object inference-error-major? drop t ;

: compile-error ( word error -- )
    batch-mode get [
        2array compile-errors get push
    ] [
        "quiet" get [ drop ] [ error. flush ] if drop
    ] if ;

: begin-batch ( seq -- )
    batch-mode on
    [
        "Compiling " % length # " words..." %
    ] "" make print flush
    V{ } clone compile-errors set-global ;

: compile-error. ( pair -- )
    nl
    "While compiling " write dup first pprint ": " print
    nl
    second error. ;

: (:errors) ( -- seq )
    compile-errors get-global
    [ second inference-error-major? ] subset ;

: :errors (:errors) [ compile-error. ] each ;

: (:warnings) ( -- seq )
    compile-errors get-global
    [ second inference-error-major? not ] subset ;

: :warnings (:warnings) [ compile-error. ] each ;

: end-batch ( -- )
    batch-mode off
    "quiet" get [
        "Compile finished." print
        nl
        ":errors - print " write (:errors) length pprint
        " compiler errors." print
        ":warnings - print " write (:warnings) length pprint
        " compiler warnings." print
        nl
    ] unless ;

: word-dataflow ( word -- dataflow )
    [
        dup "no-effect" word-prop [ no-effect ] when
        dup dup add-recursive-state
        [ specialized-def (dataflow) ] keep
        finish-word 2drop
    ] with-infer ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        dup compile-begins
        dup dup word-dataflow optimize generate
    ] [
        drop
    ] if ;

: compile ( word -- )
    [ (compile) ] with-compiler ;

: compile-failed ( word error -- )
    dupd compile-error dup update-xt unchanged-word ;

: try-compile ( word -- )
    [ compile ] [ compile-failed ] recover ;

: forget-errors ( seq -- )
    [ f "no-effect" set-word-prop ] each ;

: compile-batch ( seq -- )
    dup empty? [
        drop
    ] [
        dup begin-batch
        dup forget-errors
        [ try-compile ] each
        end-batch
    ] if ;

: compile-vocabs ( seq -- ) [ words ] map concat compile-batch ;

: compile-all ( -- ) vocabs compile-vocabs ;

: compile-quot ( quot -- word ) define-temp dup compile ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    changed-words get [
        dup keys compile-batch clear-assoc
    ] when* ;
