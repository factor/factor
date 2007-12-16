! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
generator debugger math.parser prettyprint words continuations
vocabs assocs alien.compiler ;
IN: compiler

M: object inference-error-major? drop t ;

: compile-error ( word error -- )
    compile-errors get [
        >r 2array r> push
    ] [
        "quiet" get [ 2drop ] [ print-error flush drop ] if
    ] if* ;

: begin-batch ( -- )
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
    "quiet" get [
        "Compile finished." print
        nl
        ":errors - print " write (:errors) length pprint
        " compiler errors." print
        ":warnings - print " write (:warnings) length pprint
        " compiler warnings." print
        nl
    ] unless ;

: with-compile-errors ( quot -- )
    [ begin-batch call end-batch ] with-scope ; inline

: compile ( word -- )
    H{ } clone [
        compiled-xts [ (compile) ] with-variable
    ] keep [ swap add* ] { } assoc>map modify-code-heap ;

: compile-failed ( word error -- )
    dupd compile-error dup update-xt unchanged-word ;

: (compile-batch) ( words -- )
    H{ } clone [
        compiled-xts [
            [ [ (compile) ] [ compile-failed ] recover ] each
        ] with-variable
    ] keep [ swap add* ] { } assoc>map modify-code-heap ;

: compile-batch ( seq -- )
    dup empty? [
        drop
    ] [
        [ (compile-batch) ] with-compile-errors
    ] if ;

: compile-vocabs ( seq -- ) [ words ] map concat compile-batch ;

: compile-quot ( quot -- word ) define-temp dup compile ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    changed-words get [
        dup keys compile-batch clear-assoc
    ] when* ;

: forget-errors ( seq -- )
    [ f "no-effect" set-word-prop ] each ;

: compile-all ( -- )
    all-words dup forget-errors [ changed-word ] each recompile ;
