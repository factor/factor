USING: accessors combinators definitions effects fry hints
kernel kernel.private parser sequences words ;
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
    2drop ;

! defining typed words

PREDICATE: typed < word "typed" word-prop ;

: typed-def ( word def effect -- quot )
    [ swap ] dip
    [ effect-in-types dup typed-stack-effect? [ typed-inputs ] [ 2drop ] if ] 
    [ effect-out-types dup typed-stack-effect? [ typed-outputs ] [ 2drop ] if ] 2bi ;

: define-typed ( word def effect -- )
    [ [ 2drop ] [ typed-def ] [ 2nip ] 3tri define-declared ]
    [ drop "typed" set-word-prop ] 3bi ;

SYNTAX: TYPED:
    (:) define-typed ;

M: typed definer drop \ TYPED: \ ; ;
M: typed definition "typed" word-prop ;

