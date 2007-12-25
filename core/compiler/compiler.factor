! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
generator debugger math.parser prettyprint words words.private
continuations vocabs assocs alien.compiler dlists optimizer
definitions ;
IN: compiler

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
        [ queue-compile ] each
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
            print-error f
        ] recover
        2dup ripple-up save-effect
    ] [ drop ] if ;

: compile ( words -- )
    [
        <dlist> compile-queue set
        H{ } clone compiled-xts set
        [ queue-compile ] each
        compile-queue get [ (compile) ] dlist-slurp
        compiled-xts get >alist modify-code-heap
    ] with-scope ; inline

: compile-quot ( quot -- word )
    [ define-temp ] with-compilation-unit ;

: compile-call ( quot -- )
    compile-quot execute ;

: compile-all ( -- )
    all-words compile ;
