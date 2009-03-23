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
    [ length ] keep [ [ narray ] dip swap 2array flip ] 2curry
    [ 2 ndip descriptive-error ] 2curry ;

: [descriptive] ( word def effect -- newdef )
    swapd in>> rethrower [ recover ] 2curry ;

PRIVATE>

: define-descriptive ( word def effect -- )
    [ drop "descriptive-definition" set-word-prop ]
    [ [ [ dup ] 2dip [descriptive] ] keep define-declared ]
    3bi ;

SYNTAX: DESCRIPTIVE: (:) define-descriptive ;

PREDICATE: descriptive < word
    "descriptive-definition" word-prop ;

M: descriptive definer drop \ DESCRIPTIVE: \ ; ;

M: descriptive definition
    "descriptive-definition" word-prop ;

SYNTAX: DESCRIPTIVE:: (::) define-descriptive ;

INTERSECTION: descriptive-lambda descriptive lambda-word ;

M: descriptive-lambda definer drop \ DESCRIPTIVE:: \ ; ;

M: descriptive-lambda definition
    "lambda" word-prop body>> ;
