! (c)Joe Groff bsd license
USING: accessors arrays classes classes.tuple combinators
combinators.short-circuit definitions effects fry hints
math kernel kernel.private namespaces parser quotations
sequences slots words locals effects.parser
locals.parser macros stack-checker.dependencies ;
FROM: classes.tuple.private => tuple-layout ;
IN: typed

ERROR: type-mismatch-error word expected-types ;
ERROR: input-mismatch-error < type-mismatch-error ;
ERROR: output-mismatch-error < type-mismatch-error ;

PREDICATE: typed-gensym < word "typed-gensym" word-prop >boolean ;
PREDICATE: typed-word < word "typed-word" word-prop >boolean ;

<PRIVATE

: unboxable-tuple-class? ( type -- ? )
    {
        [ all-slots empty? not ]
        [ immutable-tuple-class? ]
        [ final-class? ]
    } 1&& ;

! typed inputs

: typed-stack-effect? ( effect -- ? )
    [ object = ] all? not ;

: input-mismatch-quot ( word types -- quot )
    [ input-mismatch-error ] 2curry ;

: depends-on-unboxing ( class -- )
    [ dup tuple-layout depends-on-tuple-layout ]
    [ depends-on-final ]
    bi ;

: (unboxer) ( type -- quot )
    dup unboxable-tuple-class? [
        dup depends-on-unboxing
        all-slots [
            [ name>> reader-word 1quotation ]
            [ class>> (unboxer) ] bi compose
        ] map [ cleave ] curry
    ] [ drop [ ] ] if ;

:: unboxer ( error-quot word types type -- quot )
    type "coercer" word-prop [ ] or
    [ dup type instance? [ word types error-quot call ] unless ]
    type (unboxer)
    compose compose ;

: make-unboxer ( error-quot word types -- quot )
    dup [ unboxer ] with with with
    [ swap \ dip [ ] 2sequence prepend ] map-reduce ;

: (unboxed-types) ( type -- types )
    dup unboxable-tuple-class?
    [
        dup depends-on-unboxing
        all-slots [ class>> (unboxed-types) ] map concat
    ]
    [ 1array ] if ;

: unboxed-types ( types -- types' )
    [ (unboxed-types) ] map concat ;

:: typed-inputs ( quot word types -- quot' )
    types unboxed-types :> unboxed-types

    [ input-mismatch-error ] word types make-unboxer
    unboxed-types quot '[ _ declare @ ]
    compose ;

! typed outputs

: output-mismatch-quot ( word types -- quot )
    [ output-mismatch-error ] 2curry ;

:: typed-outputs ( quot word types -- quot' )
    [ output-mismatch-error ] word types make-unboxer
    quot prepose ;

DEFER: make-boxer

: boxer ( type -- quot )
    dup unboxable-tuple-class?
    [
        dup depends-on-unboxing
        [ all-slots [ class>> ] map make-boxer ]
        [ [ boa ] curry ]
        bi compose
    ]
    [ drop [ ] ] if ;

: make-boxer ( types -- quot )
    [ [ ] ]
    [ [ boxer ] [ swap '[ @ _ dip ] ] map-reduce ] if-empty ;

! defining typed words

MACRO: (typed) ( word def effect -- quot )
    [ swap ] dip
    [
        nip effect-in-types swap
        [ [ unboxed-types ] [ make-boxer ] bi ] dip
        '[ _ declare @ @ ]
    ]
    [
        effect-out-types
        dup typed-stack-effect? [ typed-outputs ] [ 2drop ] if
    ] 2bi ;

: <typed-gensym> ( parent-word -- word )
    [ name>> "( typed " " )" surround f <word> dup ]
    [ "typed-gensym" set-word-prop ] bi ;

: unboxed-effect ( effect -- effect' )
    [ effect-in-types unboxed-types [ "in" swap 2array ] map ]
    [ effect-out-types unboxed-types [ "out" swap 2array ] map ] bi <effect> ;

M: typed-gensym stack-effect call-next-method unboxed-effect ;
M: typed-gensym parent-word "typed-gensym" word-prop ;
M: typed-gensym crossref? parent-word crossref? ;
M: typed-gensym where parent-word where ;

: define-typed-gensym ( word def effect -- gensym )
    [ 2drop <typed-gensym> dup ]
    [ [ (typed) ] 3curry ]
    [ 2nip ] 3tri define-declared ;

MACRO: typed ( quot word effect -- quot' )
    [ effect-in-types dup typed-stack-effect? [ typed-inputs ] [ 2drop ] if ] 
    [
        nip effect-out-types dup typed-stack-effect?
        [ [ unboxed-types ] [ make-boxer ] bi '[ @ _ declare @ ] ] [ drop ] if
    ] 2bi ;

: (typed-def) ( word def effect -- quot )
    [ define-typed-gensym ] 3keep
    [ drop [ swap "typed-word" set-word-prop ] [ [ 1quotation ] dip ] 2bi ] dip
    [ typed ] 3curry ;

: typed-def ( word def effect -- quot )
    dup {
        [ effect-in-types typed-stack-effect? ]
        [ effect-out-types typed-stack-effect? ]
    } 1|| [ (typed-def) ] [ drop nip ] if ;

M: typed-word subwords
    [ call-next-method ]
    [ "typed-word" word-prop ] bi suffix ;

PRIVATE>

: define-typed ( word def effect -- )
    [ [ 2drop ] [ typed-def ] [ 2nip ] 3tri define-inline ] 
    [ drop "typed-def" set-word-prop ]
    [ 2drop "typed-word" word-prop \ word set-global ] 3tri ;

SYNTAX: TYPED:
    (:) define-typed ;
SYNTAX: TYPED::
    (::) define-typed ;

USE: vocabs.loader

{ "typed" "prettyprint" } "typed.prettyprint" require-when
