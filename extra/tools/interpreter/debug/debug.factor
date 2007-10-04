! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.interpreter namespaces kernel arrays continuations
threads sequences ;
IN: tools.interpreter.debug

: run-interpreter ( -- )
    interpreter get [ step-into run-interpreter ] when ;

: init-interpreter ( quot -- )
    [
        "out" set
        [ f swap 2array restore "out" get continue ] callcc0
    ] swap [ datastack "datastack" set stop ]
    3append callcc0 ;

: test-interpreter ( quot -- )
    init-interpreter run-interpreter "datastack" get ;
