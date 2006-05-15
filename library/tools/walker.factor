! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: walker
USING: errors hashtables inspector interpreter io kernel
listener math namespaces prettyprint sequences strings
vectors words ;

: &s ( -- ) meta-d get stack. ;

: &r ( -- ) meta-r get stack. ;

: meta-c*
    [ meta-c get % meta-executing get , meta-cf get , ] { } make ;

: &c ( -- ) meta-c* stack. ;

: &get ( var -- value ) meta-name get hash-stack ;

: report ( -- ) meta-cf get . ;

: step ( -- ) next do-1 report ;

: into ( -- ) next do report ;

: end-walk ( -- )
    \ call push-c meta-cf get push-c meta-interp continue ;

: walk-banner ( -- )
    "&s &r &c show stepper stacks" print
    "&get ( var -- value ) get stepper variable value" print
    "step -- single step over" print
    "into -- single step into" print
    "bye -- continue execution" print
    report ;

: set-walk-hooks ( -- )
    [ meta-d get ] datastack-hook set
    "walk " listener-prompt set ;

: walk ( quot -- )
    datastack dup pop*
    retainstack
    callstack
    namestack
    catchstack [
        meta-catch set
        meta-name set
        meta-c set
        meta-r set
        meta-d set
        meta-cf set
        meta-executing off
        set-walk-hooks
        walk-banner
        listener end-walk
    ] with-scope ;
