! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: interpreter
USING: errors kernel listener lists math namespaces prettyprint
stdio strings vectors words ;

: &s
    #! Print stepper data stack.
    meta-d get {.} ;

: &r
    #! Print stepper call stack, as well as the currently
    #! executing quotation.
    meta-cf get . meta-executing get . meta-r get {.} ;

: &n
    #! Print stepper name stack.
    meta-n get [.] ;

: &c
    #! Print stepper catch stack.
    meta-c get [.] ;

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
    [ &s &r &n &c ] [ prettyprint-word " " write ] each
    "show stepper stacks." print
    \ &get prettyprint-word
    " ( var -- value ) inspects the stepper namestack." print
    \ step prettyprint-word " -- single step over" print
    \ into prettyprint-word " -- single step into" print
    \ continue prettyprint-word " -- continue execution" print
    \ bye prettyprint-word " -- exit single-stepper" print
    report ;

: walk-listener walk-banner "walk" listener-prompt set listener ;

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
