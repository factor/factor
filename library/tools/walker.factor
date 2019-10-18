! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: walker
USING: errors hashtables inspector interpreter io kernel
listener math namespaces prettyprint sequences strings
vectors words ;

: &s ( -- ) meta-d get stack. ;

: &r ( -- ) meta-r get stack. ;

: meta-c* ( -- seq ) meta-c get meta-callframe append ;

: &c ( -- ) meta-c* callstack. ;

: &get ( var -- value ) meta-name get hash-stack ;

: report ( -- ) callframe get callframe-scan get callframe. ;

: step ( -- ) next do-1 report ;

: into ( -- ) next do report ;

: end-walk ( -- )
    save-callframe meta-interp continue ;

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
    continuation [
        set-meta-interp pop-d drop (meta-call)
        set-walk-hooks walk-banner (listener) end-walk
    ] with-scope ;
