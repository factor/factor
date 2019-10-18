! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: walker
USING: errors hashtables inspector interpreter io kernel
listener lists math namespaces prettyprint sequences strings
vectors words ;

: &s ( -- ) meta-d get stack. ;

: meta-r*
    [ meta-r get % meta-executing get , meta-cf get , ] { } make ;

: &r ( -- ) meta-r* stack. ;

: &get ( var -- value ) meta-n get hash-stack ;

: report ( -- ) meta-cf get . ;

: step ( -- ) next do-1 report ;

: into ( -- ) next do report ;

: end-walk ( -- )
    \ call push-r meta-cf get push-r meta-interp continue ;

: walk-banner ( -- )
    "&s &r show stepper stacks" print
    "&get ( var -- value ) get stepper variable value" print
    "step -- single step over" print
    "into -- single step into" print
    "bye -- continue execution" print
    report ;

: set-walk-hooks ( -- )
    [ meta-d get ] datastack-hook set
    "walk " listener-prompt set ;

: walk ( quot -- )
    datastack dup pop* callstack namestack catchstack [
        meta-c set meta-n set meta-r set meta-d set
        meta-cf set
        meta-executing off
        set-walk-hooks
        walk-banner
        listener end-walk
    ] with-scope ;
