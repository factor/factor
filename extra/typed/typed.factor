! (c)Joe Groff bsd license
USING: accessors arrays classes classes.tuple combinators
combinators.short-circuit definitions effects fry hints
math kernel kernel.private namespaces parser quotations
see.private sequences slots words locals locals.definitions
locals.parser ;
IN: typed

ERROR: type-mismatch-error word expected-types ;
ERROR: input-mismatch-error < type-mismatch-error ;
ERROR: output-mismatch-error < type-mismatch-error ;

: unboxable-tuple-class? ( type -- ? )
    {
        [ all-slots empty? not ]
        [ immutable-tuple-class? ]
    } 1&& ;

! typed inputs

: typed-stack-effect? ( effect -- ? )
    [ object = ] all? not ;

: input-mismatch-quot ( word types -- quot )
    [ input-mismatch-error ] 2curry ;

: (unboxer) ( type -- quot )
    dup unboxable-tuple-class? [
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
    [ all-slots [ class>> (unboxed-types) ] map concat ]
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
    [ [ all-slots [ class>> ] map make-boxer ] [ [ boa ] curry ] bi compose ]
    [ drop [ ] ] if ;

: make-boxer ( types -- quot )
    [ boxer ] [ swap '[ @ _ dip ] ] map-reduce ;

! defining typed words

: typed-gensym-quot ( def word effect -- quot )
    [
        nip effect-in-types swap
        [ [ unboxed-types ] [ make-boxer ] bi ] dip
        '[ _ declare @ @ ]
    ]
    [ effect-out-types dup typed-stack-effect? [ typed-outputs ] [ 2drop ] if ] 2bi ;

: typed-gensym ( parent-word -- word )
    name>> "( typed " " )" surround f <word> ;

: unboxed-effect ( effect -- effect' )
    [ effect-in-types unboxed-types [ "in" swap 2array ] map ]
    [ effect-out-types unboxed-types [ "out" swap 2array ] map ] bi <effect> ;

: define-typed-gensym ( word def effect -- gensym )
    [ 2drop typed-gensym dup ]
    [ [ swap ] dip typed-gensym-quot ]
    [ 2nip unboxed-effect ] 3tri define-declared ;

PREDICATE: typed-standard-word < word "typed-word" word-prop ;
PREDICATE: typed-lambda-word < lambda-word "typed-word" word-prop ;

UNION: typed-word typed-standard-word typed-lambda-word ;

: typed-quot ( quot word effect -- quot' )
    [ effect-in-types dup typed-stack-effect? [ typed-inputs ] [ 2drop ] if ] 
    [
        nip effect-out-types dup typed-stack-effect?
        [ [ unboxed-types ] [ make-boxer ] bi '[ @ _ declare @ ] ] [ drop ] if
    ] 2bi ;

: (typed-def) ( word def effect -- quot )
    [ define-typed-gensym ] 3keep
    [ drop [ swap "typed-word" set-word-prop ] [ [ 1quotation ] dip ] 2bi ] dip
    typed-quot ;

: typed-def ( word def effect -- quot )
    dup {
        [ effect-in-types typed-stack-effect? ]
        [ effect-out-types typed-stack-effect? ]
    } 1|| [ (typed-def) ] [ drop nip ] if ;

: define-typed ( word def effect -- )
    [ [ 2drop ] [ typed-def ] [ 2nip ] 3tri define-inline ] 
    [ drop "typed-def" set-word-prop ]
    [ 2drop "typed-word" word-prop \ word set-global ] 3tri ;

SYNTAX: TYPED:
    (:) define-typed ;
SYNTAX: TYPED::
    (::) define-typed ;

M: typed-standard-word definer drop \ TYPED: \ ; ;
M: typed-lambda-word definer drop \ TYPED:: \ ; ;

M: typed-word definition "typed-def" word-prop ;
M: typed-word declarations. "typed-word" word-prop declarations. ;

M: typed-word subwords "typed-word" word-prop 1array ;
