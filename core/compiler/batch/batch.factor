! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces dlists kernel words inference.backend
optimizer arrays definitions sequences assocs
continuations generator compiler ;
IN: compiler.batch

: with-compilation-unit ( quot -- )
    H{ } clone
    [ compiled-xts swap with-variable ] keep
    [ swap add* ] { } assoc>map modify-code-heap ;

: compile-batch ( words -- )
    [ [ (compile) ] curry [ print-error ] recover ] each ;

SYMBOL: compile-queue

: queue-compile ( word -- )
    compile-queue get push-front ;

: compiled-usage ( word -- seq )
    #! XXX
    usage [ word? ] subset ;

: ripple-up ( effect word -- )
    tuck "compiled-effect" word-prop =
    [ drop ] [ compiled-usage [ queue-compile ] each ] if ;

: save-effect ( effect word -- )
    swap "compiled-effect" set-word-prop ;

: add-compiled ( word -- )
    >r f f f f f <compiled> r> compile-results get set-at ;

: compile-1 ( word -- )
    dup compile-results get at [ drop ] [
        [ [ word-dataflow drop ] [ 2drop f ] recover ] keep
        2dup ripple-up
        tuck save-effect
        add-compiled
    ] if ;

: compile-batch ( words -- )
    [
        <dlist> compile-queue set
        [ queue-compile ] each
        H{ } clone compile-results set
        compile-queue get [ compile-1 ] dlist-slurp
        compile-results get
    ] with-scope ;
