! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words parser io inspector quotations sequences
prettyprint continuations effects definitions compiler.units ;
IN: tools.annotations

: reset ( word -- )
    dup "unannotated-def" word-prop [
        [
            dup dup "unannotated-def" word-prop define
        ] with-compilation-unit
        f "unannotated-def" set-word-prop
    ] [ drop ] if ;

: annotate ( word quot -- )
    over "unannotated-def" word-prop [
        "Cannot annotate a word twice" throw
    ] when
    [
        over dup word-def "unannotated-def" set-word-prop
        >r dup word-def r> call define
    ] with-compilation-unit ; inline

: word-inputs ( word -- seq )
    stack-effect [
        >r datastack r> effect-in length tail*
    ] [
        datastack
    ] if* ;

: entering ( str -- )
    "/-- Entering: " write dup .
    word-inputs stack.
    "\\--" print flush ;

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

: breakpoint-if ( word quot -- )
    [ [ [ break ] when ] rot 3append ] curry annotate ;
