! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sorting words parser io summary
quotations sequences prettyprint continuations effects
definitions compiler.units namespaces assocs tools.time generic
inspector fry locals generalizations macros ;
IN: tools.annotations

<PRIVATE

GENERIC: (reset) ( word -- )

M: generic (reset)
    subwords [ (reset) ] each ;

M: word (reset)
    dup "unannotated-def" word-prop [
        dup dup "unannotated-def" word-prop define
        f "unannotated-def" set-word-prop
    ] [ drop ] if ;

PRIVATE>

: reset ( word -- )
    [ (reset) ] with-compilation-unit ;

ERROR: cannot-annotate-twice word ;

M: cannot-annotate-twice summary drop "Cannot annotate a word twice" ;

<PRIVATE

: check-annotate-twice ( word -- word )
    dup "unannotated-def" word-prop [
        cannot-annotate-twice
    ] when ;

GENERIC# (annotate) 1 ( word quot -- )

M: generic (annotate)
    [ "methods" word-prop values ] dip '[ _ (annotate) ] each ;

M: word (annotate)
    [ check-annotate-twice ] dip
    [ dup def>> 2dup "unannotated-def" set-word-prop ] dip
    call( old -- new ) define ;

PRIVATE>

: annotate ( word quot -- )
    [ (annotate) ] with-compilation-unit ;

<PRIVATE

:: trace-quot ( word effect quot str -- quot' )
    effect quot call :> values
    values length :> n
    [
        "--- " write str write bl word .
        n ndup n narray values swap zip simple-table.
        flush
    ] ; inline

MACRO: entering ( word -- quot )
    dup stack-effect [ in>> ] "Entering" trace-quot ;

MACRO: leaving ( word -- quot )
    dup stack-effect [ out>> ] "Leaving" trace-quot ;

: (watch) ( word def -- def )
    over '[ _ entering @ _ leaving ] ;

PRIVATE>

: watch ( word -- )
    dup '[ [ _ ] dip (watch) ] annotate ;

<PRIVATE

: (watch-vars) ( word vars quot -- newquot )
   '[
        "--- Entering: " write _ .
        "--- Variable values:" print _ [ dup get ] H{ } map>assoc describe
        @
    ] ;

PRIVATE>

: watch-vars ( word vars -- )
    dupd '[ [ _ _ ] dip (watch-vars) ] annotate ;

SYMBOL: word-timing

word-timing [ H{ } clone ] initialize

: reset-word-timing ( -- )
    word-timing get clear-assoc ;

<PRIVATE

: (add-timing) ( def word -- def' )
    '[ _ benchmark _ word-timing get at+ ] ;

PRIVATE>

: add-timing ( word -- )
    dup '[ _ (add-timing) ] annotate ;

: word-timing. ( -- )
    word-timing get
    >alist [ 1000000 /f ] assoc-map sort-values
    simple-table. ;
