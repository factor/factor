USING: kernel sequences math stack-checker effects accessors
macros fry combinators.short-circuit ;
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
