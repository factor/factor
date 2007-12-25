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
    [
        dup compile-begins
        dup word-dataflow optimize >r over dup r> generate
    ] [
        print-error f
    ] recover
    2dup ripple-up save-effect ;

: delete-any ( assoc -- element )
    [ [ 2drop t ] assoc-find 2drop dup ] keep delete-at ;

: compile-loop ( assoc -- )
    dup assoc-empty?
    [ drop ] [ dup delete-any (compile) compile-loop ] if ;

: compile ( words -- )
    [
        H{ } clone compile-queue set
        H{ } clone compiled set
        [ queue-compile ] each
        compile-queue get compile-loop
        compiled get >alist modify-code-heap
    ] with-scope ; inline

: compile-quot ( quot -- word )
    H{ } clone changed-words [
        define-temp dup 1array compile
    ] with-variable ;

: compile-call ( quot -- )
    compile-quot execute ;

: compile-all ( -- )
    all-words compile ;
