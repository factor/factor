! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: interpreter
USING: errors kernel listener lists math namespaces prettyprint
stdio strings vectors words ;

: &s
    #! Print stepper data stack.
    meta-d get {.} ;

: &r
    #! Print stepper call stack.
    meta-r get {.} meta-cf get . ;

: &n
    #! Print stepper name stack.
    meta-n get [.] ;

: &c
    #! Print stepper catch stack.
    meta-c get [.] ;

: &get ( var -- value )
    #! Get stepper variable value.
    meta-n get (get) ;

: stack-report ( -- )
    meta-r get vector-length "=" fill write
    meta-d get vector-length "-" fill write ;

: not-done ( quot -- )
    done? [
        stack-report "Stepper is done." print drop
    ] [
        call
    ] ifte ;

: report ( -- )
    stack-report meta-cf get . ;

: step
    #! Step over current word.
    [ next do-1 report ] not-done ;

: into
    #! Step into current word.
    [ next do report ] not-done ;

: walk-banner ( -- )
    [ &s &r &n &c ] [ prettyprint-word " " write ] each
    "show stepper stacks." print
    \ &get prettyprint-word
    " ( var -- value ) inspects the stepper namestack." print
    \ step prettyprint-word " -- single step over" print
    \ into prettyprint-word " -- single step into" print
    \ exit prettyprint-word " -- exit single-stepper" print
    report ;

: walk-listener walk-banner "walk" listener-prompt set listener ;

: walk ( quot -- )
    #! Single-step through execution of a quotation.
    [
        init-interpreter
        meta-cf set
        datastack meta-d set
        walk-listener
        meta-d get
    ] with-scope set-datastack ;
