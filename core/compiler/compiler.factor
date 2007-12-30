! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
generator debugger math.parser prettyprint words words.private
continuations vocabs assocs alien.compiler dlists optimizer
definitions math compiler.errors threads ;
IN: compiler

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
        dup word-dataflow optimize >r over dup r> generate
    ] [
        dup inference-error? [ rethrow ] unless
        over compiler-error f over compiled get set-at f
    ] recover
    2drop ;
!    2dup ripple-up save-effect ;

: delete-any ( assoc -- element )
    [ [ 2drop t ] assoc-find 2drop dup ] keep delete-at ;

: compile-loop ( assoc -- )
    dup assoc-empty? [ drop ] [
        dup delete-any (compile)
        yield
        compile-loop
    ] if ;

: recompile ( words -- )
    [
        H{ } clone compile-queue set
        H{ } clone compiled set
        [ queue-compile ] each
        compile-queue get compile-loop
        compiled get >alist modify-code-heap
    ] with-scope ; inline

: compile ( words -- )
    [ compiled? not ] subset recompile ;

: compile-call ( quot -- )
    H{ } clone changed-words [
        define-temp dup 1array recompile
    ] with-variable execute ;

: recompile-all ( -- )
    [ all-words recompile ] with-compiler-errors ;

: decompile ( word -- )
    f 2array 1array modify-code-heap ;
