USING: words kernel sequences locals locals.parser
locals.definitions accessors parser namespaces continuations
summary definitions generalizations arrays ;
IN: descriptive

ERROR: descriptive-error args underlying word ;

M: descriptive-error summary
    word>> "The " swap name>> " word encountered an error."
    3append ;

<PRIVATE
: rethrower ( word inputs -- quot )
    [ length ] keep [ >r narray r> swap 2array flip ] 2curry
    [ 2 ndip descriptive-error ] 2curry ;

: [descriptive] ( word def -- newdef )
    swap dup "declared-effect" word-prop in>> rethrower
    [ recover ] 2curry ;
PRIVATE>

: define-descriptive ( word def -- )
    [ "descriptive-definition" set-word-prop ]
    [ dupd [descriptive] define ] 2bi ;

: DESCRIPTIVE:
    (:) define-descriptive ; parsing

PREDICATE: descriptive < word
    "descriptive-definition" word-prop ;

M: descriptive definer drop \ DESCRIPTIVE: \ ; ;

M: descriptive definition
    "descriptive-definition" word-prop ;

: DESCRIPTIVE::
    (::) define-descriptive ; parsing

INTERSECTION: descriptive-lambda descriptive lambda-word ;

M: descriptive-lambda definer drop \ DESCRIPTIVE:: \ ; ;

M: descriptive-lambda definition
    "lambda" word-prop body>> ;
