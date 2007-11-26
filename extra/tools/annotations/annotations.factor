! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words parser io inspector quotations sequences
prettyprint continuations effects ;
IN: tools.annotations

: annotate ( word quot -- )
    over >r >r word-def r> call r>
    swap define-compound do-parse-hook ;
    inline

: entering ( str -- )
    "/-- Entering: " write dup .
    stack-effect [
        >r datastack r> effect-in length tail* stack.
    ] [
        .s
    ] if* "\\--" print flush ;

: leaving ( str -- )
    "/-- Leaving: " write dup .
    stack-effect [
        >r datastack r> effect-out length tail* stack.
    ] [
        .s
    ] if* "\\--" print flush ;

: (watch) ( word def -- def )
    over [ entering ] curry
    rot [ leaving ] curry
    swapd 3append ;

: watch ( word -- )
    dup [ (watch) ] annotate ;

: breakpoint ( word -- )
    [ \ break add* ] annotate ;

: breakpoint-if ( quot word -- )
    [ [ [ break ] when ] swap 3append ] annotate ;
