USING: accessors combinators.short-circuit effects kernel math
sequences stack-checker ;
IN: combinators.short-circuit.smart

<PRIVATE

ERROR: cannot-determine-arity ;

: arity ( quots -- n )
    first infer
    dup terminated?>> [ cannot-determine-arity ] when
    effect-height neg 1 + ;

PRIVATE>

MACRO: && ( quots -- quot ) dup arity '[ _ _ n&& ] ;

MACRO: || ( quots -- quot ) dup arity '[ _ _ n|| ] ;
