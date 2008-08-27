
USING: kernel sequences math stack-checker effects accessors macros
       combinators.short-circuit ;

IN: combinators.short-circuit.smart

<PRIVATE

: arity ( quots -- n )
    first infer
    dup terminated?>> [ "Cannot determine arity" throw ] when
    effect-height neg 1+ ;

PRIVATE>

MACRO: && ( quots -- quot ) dup arity n&&-rewrite ;

MACRO: || ( quots -- quot ) dup arity n||-rewrite ;
