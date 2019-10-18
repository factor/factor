! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
generator debugger math.parser prettyprint words continuations
vocabs assocs alien.compiler ;
IN: compiler

M: object inference-error-major? drop t ;

: compile-error ( word error -- )
    batch-mode get [
        2array compile-errors get push
    ] [
        "quiet" get [ drop ] [ print-error flush ] if drop
    ] if ;

: begin-batch ( seq -- )
    batch-mode on
    "quiet" get [ drop ] [
        [ "Compiling " % length # " words..." % ] "" make
        print flush
    ] if
    V{ } clone compile-errors set-global ;

: compile-error. ( pair -- )
    nl
    "While compiling " write dup first pprint ": " print
    nl
    second print-error ;

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

: compile ( word -- )
    H{ } clone [
        compiled-xts [ (compile) ] with-variable
    ] keep >alist finalize-compile ;

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

: recompile-all ( -- )
    all-words [ changed-word ] each recompile ;
