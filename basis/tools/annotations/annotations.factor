! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel words parser io summary quotations
sequences prettyprint continuations effects definitions
compiler.units namespaces assocs tools.walker generic
inspector fry ;
IN: tools.annotations

GENERIC: reset ( word -- )

M: generic reset
    [ call-next-method ]
    [ subwords [ reset ] each ] bi ;

M: word reset
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
        over dup def>> "unannotated-def" set-word-prop
        [ dup def>> ] dip call define
    ] with-compilation-unit ; inline

: word-inputs ( word -- seq )
    stack-effect [
        [ datastack ] dip in>> length tail*
    ] [
        datastack
    ] if* ;

: entering ( str -- )
    "/-- Entering: " write dup .
    word-inputs stack.
    "\\--" print flush ;

: word-outputs ( word -- seq )
    stack-effect [
        [ datastack ] dip out>> length tail*
    ] [
        datastack
    ] if* ;

: leaving ( str -- )
    "/-- Leaving: " write dup .
    word-outputs stack.
     "\\--" print flush ;

: (watch) ( word def -- def )
    over '[ _ entering @ _ leaving ] ;

: watch ( word -- )
    dup [ (watch) ] annotate ;

: (watch-vars) ( word vars quot -- newquot )
   '[
        "--- Entering: " write _ .
        "--- Variable values:" print _ [ dup get ] H{ } map>assoc describe
        @
    ] ;

: watch-vars ( word vars -- )
    dupd '[ [ _ _ ] dip (watch-vars) ] annotate ;

GENERIC# annotate-methods 1 ( word quot -- )

M: generic annotate-methods
    [ "methods" word-prop values ] dip [ annotate ] curry each ;

M: word annotate-methods
    annotate ;

: breakpoint ( word -- )
    [ add-breakpoint ] annotate-methods ;

: breakpoint-if ( word quot -- )
    '[ [ _ [ [ break ] when ] ] dip 3append ] annotate-methods ;
