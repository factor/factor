USING: words kernel sequences combinators.lib locals
locals.private accessors parser namespaces continuations
inspector definitions arrays.lib arrays ;
IN: descriptive

ERROR: descriptive args underlying word ;

M: descriptive summary
    word>> "The " swap word-name " word encountered an error."
    3append ;

<PRIVATE
: rethrower ( word inputs -- quot )
    [ length ] keep [ >r narray r> swap 2array flip ] 2curry
    [ 2 ndip descriptive ] 2curry ;

: [descriptive] ( word def -- newdef )
    swap dup "declared-effect" word-prop in>> rethrower
    [ recover ] 2curry ;
PRIVATE>

: define-descriptive ( word def -- )
    [ "descriptive-definition" set-word-prop ]
    [ dupd [descriptive] define ] 2bi ;

: DESCRIPTIVE:
    (:) define-descriptive ; parsing

PREDICATE: descriptive-def < word
    "descriptive-definition" word-prop ;

M: descriptive-def definer drop \ DESCRIPTIVE: \ ; ;

M: descriptive-def definition
    "descriptive-definition" word-prop ;

: DESCRIPTIVE::
    (::) define-descriptive ; parsing

PREDICATE: descriptive-lambda < lambda-word
    "descriptive-definition" word-prop ;

M: descriptive-lambda definer drop \ DESCRIPTIVE:: \ ; ;

M: descriptive-lambda definition
    "lambda" word-prop body>> ;
