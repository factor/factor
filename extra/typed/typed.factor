! (c)Joe Groff bsd license
USING: accessors combinators combinators.short-circuit
definitions effects fry hints kernel kernel.private namespaces
parser quotations see.private sequences words
locals locals.definitions locals.parser ;
IN: typed

ERROR: type-mismatch-error word expected-types ;
ERROR: input-mismatch-error < type-mismatch-error ;
ERROR: output-mismatch-error < type-mismatch-error ;

! typed inputs

: typed-stack-effect? ( effect -- ? )
    [ object = ] all? not ;

: input-mismatch-quot ( word types -- quot )
    [ input-mismatch-error ] 2curry ;

: make-coercer ( types -- quot )
    [ "coercer" word-prop [ ] or ]
    [ swap \ dip [ ] 2sequence prepend ]
    map-reduce ;

: typed-inputs ( quot word types -- quot' )
    {
        [ 2nip make-coercer ]
        [ 2nip make-specializer ]
        [ nip swap '[ _ declare @ ] ]
        [ [ drop ] 2dip input-mismatch-quot ]
    } 3cleave '[ @ @ _ _ if ] ;

! typed outputs

: output-mismatch-quot ( word types -- quot )
    [ output-mismatch-error ] 2curry ;

: typed-outputs ( quot word types -- quot' )
    {
        [ 2drop ]
        [ 2nip make-coercer ]
        [ 2nip make-specializer ]
        [ [ drop ] 2dip output-mismatch-quot ]
    } 3cleave '[ @ @ @ _ unless ] ;

! defining typed words

: typed-gensym-quot ( def word effect -- quot )
    [ nip effect-in-types swap '[ _ declare @ ] ]
    [ effect-out-types dup typed-stack-effect? [ typed-outputs ] [ 2drop ] if ] 2bi ;

: define-typed-gensym ( word def effect -- gensym )
    [ 3drop gensym dup ]
    [ [ swap ] dip typed-gensym-quot ]
    [ 2nip ] 3tri define-declared ;

PREDICATE: typed-standard-word < word "typed-word" word-prop ;
PREDICATE: typed-lambda-word < lambda-word "typed-word" word-prop ;

UNION: typed-word typed-standard-word typed-lambda-word ;

: typed-quot ( quot word effect -- quot' )
    [ effect-in-types dup typed-stack-effect? [ typed-inputs ] [ 2drop ] if ] 
    [ nip effect-out-types dup typed-stack-effect? [ '[ @ _ declare ] ] [ drop ] if ] 2bi ;

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

