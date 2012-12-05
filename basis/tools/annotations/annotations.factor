! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sorting words parser io summary
quotations sequences sequences.generalizations prettyprint
continuations effects definitions compiler.units namespaces
assocs tools.time generic inspector fry locals generalizations
macros sequences.deep ;
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

: annotate-generic ( word quot -- )
    [ "methods" word-prop values ] dip each ; inline

: prepare-annotate ( word quot -- word quot quot )
    [ check-annotate-twice ] dip
    [ dup def>> 2dup "unannotated-def" set-word-prop ] dip ;

GENERIC# (annotate) 1 ( word quot -- )

M: generic (annotate)
    '[ _ (annotate) ] annotate-generic ;

M: word (annotate)
    prepare-annotate
    call( old -- new ) define ;

GENERIC# (deep-annotate) 1 ( word quot -- )

M: generic (deep-annotate)
    '[ _ (deep-annotate) ] annotate-generic ;

M: word (deep-annotate)
    prepare-annotate
    '[ dup callable? [ _ call( old -- new ) ] when ] deep-map define ;

PRIVATE>

: annotate ( word quot -- )
    [ (annotate) ] with-compilation-unit ;

: deep-annotate ( word quot -- )
    [ (deep-annotate) ] with-compilation-unit ;

<PRIVATE

:: trace-quot ( word effect quot str -- quot' )
    effect quot call :> values
    values length :> n
    [
        [
            "--- " write str write bl word .
            n ndup n narray values swap zip simple-table.
            flush
        ] with-output>error
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
        [
            "--- Entering: " write _ .
            "--- Variable values:" print _ [ dup get ] H{ } map>assoc describe
            @
        ] with-output>error
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
    >alist [ 1,000,000,000 /f ] assoc-map sort-values
    simple-table. ;
