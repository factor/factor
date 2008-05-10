USING: words kernel sequences combinators.lib locals
locals.private accessors parser namespaces continuations
inspector definitions ;
IN: descriptive

ERROR: known args underlying word ;

M: known summary
    word>> "The " swap word-name " word encountered an error."
    3append ;

: rethrower ( word inputs -- quot )
    reverse [ [ set ] curry ] map concat [ ] like
    [ H{ } make-assoc ] curry
    [ 2 ndip known ] 2curry ;

: [descriptive] ( word def -- newdef )
    swap dup "declared-effect" word-prop in>> rethrower
    [ recover ] 2curry ;

: define-descriptive ( word def -- )
    [ "descriptive-definition" set-word-prop ]
    [ dupd [descriptive] define ] 2bi ;

: DESCRIPTIVE:
    (:) define-descriptive ; parsing

PREDICATE: descriptive-word < word
    "descriptive-definition" word-prop ;

M: descriptive-word definer drop \ DESCRIPTIVE: \ ; ;

M: descriptive-word definition
    "descriptive-definition" word-prop ;

: DESCRIPTIVE::
    (::) define-descriptive ; parsing

PREDICATE: descriptive-lambda < lambda-word
    "descriptive-definition" word-prop ;

M: descriptive-lambda definer drop \ DESCRIPTIVE:: \ ; ;

M: descriptive-lambda definition
    "lambda" word-prop body>> ;
