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

: &r
    #! Print stepper call stack, as well as the currently
    #! executing quotation.
    meta-cf get short. meta-executing get . meta-r get stack. ;

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

: continue
    #! Continue executing the single-stepped continuation in the
    #! primary interpreter.
    meta-d get set-datastack
    meta-c get set-catchstack
    meta-cf get
    meta-r get
    meta-n get set-namestack
    set-callstack call ;

: walk-banner ( -- )
    "&s &r show stepper stacks" print
    "&get ( var -- value ) get stepper variable value" print
    "step -- single step over" print
    "into -- single step into" print
    "continue -- continue execution" print
    "bye -- exit single-stepper" print
    report ;

: walk-listener walk-banner "walk " listener-prompt set listener ;

: init-walk ( quot callstack namestack -- )
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
    ] with-scope ;
