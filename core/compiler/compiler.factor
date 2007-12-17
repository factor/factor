! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays sequences io inference.backend
generator debugger math.parser prettyprint words continuations
vocabs assocs alien.compiler ;
IN: compiler

: compile-batch ( words -- )
    H{ } clone [
        compiled-xts [
            [ [ (compile) ] curry [ print-error ] recover ] each
        ] with-variable
    ] keep [ swap add* ] { } assoc>map modify-code-heap ;

: compile ( word -- ) 1array compile-batch ;

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
    all-words
    dup forget-errors [ changed-word ] each
    recompile ;
