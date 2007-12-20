! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
generator debugger math.parser prettyprint words continuations
vocabs assocs alien.compiler dlists optimizer ;
IN: compiler

: finish-compilation-unit ( assoc -- )
    [ swap add* ] { } assoc>map modify-code-heap ;

SYMBOL: compiler-hook

: compile-begins ( word -- )
    compiler-hook get [ call ] when*
    "quiet" get [ drop ] [ "Compiling " write . flush ] if ;

: compiled-usage ( word -- seq )
    #! XXX
    usage [ word? ] subset ;

: ripple-up ( word effect -- )
    over "compiled-effect" word-prop =
    [ drop ] [
        compiled-usage
        [ "was-compiled" word-prop ] subset
        [ dup changed-word queue-compile ] each
    ] if ;

: save-effect ( word effect -- )
    over t "was-compiled" set-word-prop
    "compiled-effect" set-word-prop ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        [
            dup compile-begins
            dup word-dataflow optimize >r over dup r> generate
        ] [
            print-error
            dup update-xt dup unchanged-word f
        ] recover
        2dup ripple-up save-effect
    ] [ drop ] if ;

: with-compilation-unit ( quot -- )
    [
        <dlist> compile-queue set
        H{ } clone compiled-xts set
        call
        compile-queue get [ (compile) ] dlist-slurp
        compiled-xts get finish-compilation-unit
    ] with-scope ; inline

: compile-batch ( words -- )
    [ [ queue-compile ] each ] with-compilation-unit ;

: compile ( word -- )
    [ queue-compile ] with-compilation-unit ;

: compile-vocabs ( seq -- )
    [ words ] map concat compile-batch ;

: compile-quot ( quot -- word )
    define-temp dup compile ;

: compile-1 ( quot -- )
    compile-quot execute ;

: recompile ( -- )
    changed-words get [
        dup keys compile-batch clear-assoc
    ] when* ;

: forget-errors ( seq -- )
    [ f "no-effect" set-word-prop ] each ;

: compile-all ( -- )
    all-words
    dup forget-errors [ changed-word ] each
    recompile ;
