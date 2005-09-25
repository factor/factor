! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: interpreter
USING: errors kernel listener lists math namespaces prettyprint
sequences io strings vectors words ;

! The single-stepper simulates Factor in Factor to allow
! single-stepping through the execution of a quotation. It can
! transfer the continuation to and from the primary interpreter.

: &s
    #! Print stepper data stack.
    meta-d get stack. ;

: meta-r*
    #! Stepper call stack, as well as the currently
    #! executing quotation.
    [ meta-r get % meta-executing get , meta-cf get , ] { } make ;

: &r
    #! Print stepper call stack, as well as the currently
    #! executing quotation.
    meta-r* stack. ;

: &get ( var -- value )
    #! Get stepper variable value.
    meta-n get (get) ;

: report ( -- ) meta-cf get . ;

: step
    #! Step over current word.
    next do-1 report ;

: into
    #! Step into current word.
    next do report ;

: end-walk
    #! Continue executing the single-stepped continuation in the
    #! primary interpreter.
    \ call push-r meta-cf get push-r meta-interp continue ;

: walk-banner ( -- )
    "&s &r show stepper stacks" print
    "&get ( var -- value ) get stepper variable value" print
    "step -- single step over" print
    "into -- single step into" print
    "bye -- continue execution" print
    report ;

: walk-listener walk-banner "walk " listener-prompt set listener ;

: init-walk ( quot callstack namestack -- )
    [ meta-d get "Stepper data stack:" ] datastack-hook set
    [ meta-r* "Stepper return stack:" ] callstack-hook set
    init-interpreter
    meta-n set
    meta-r set
    meta-cf set
    datastack meta-d set ;

: walk ( quot -- )
    #! Single-step through execution of a quotation.
    callstack namestack [
        init-walk
        walk-listener
        end-walk
    ] with-scope ;
