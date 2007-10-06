! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.interpreter kernel arrays continuations threads
sequences namespaces ;
IN: tools.interpreter.debug

: run-interpreter ( interpreter -- )
    dup interpreter-continuation [
        dup step-into run-interpreter
    ] [
        drop
    ] if ;

: quot>cont ( quot -- cont )
    [
        swap [
            continue-with
        ] curry callcc0 call stop
    ] curry callcc1 ;

: init-interpreter ( quot interpreter -- )
    >r
    [ datastack "datastack" set ] compose quot>cont
    f swap 2array
    r> restore ;

: test-interpreter ( quot -- )
    <interpreter>
    [ init-interpreter ] keep
    run-interpreter
    "datastack" get ;
