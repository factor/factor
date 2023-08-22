! Copyright (c) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations debugger definitions
effects effects.parser generalizations io kernel
locals.definitions locals.parser prettyprint sequences
sequences.generalizations tools.annotations words ;
IN: descriptive

ERROR: descriptive-error args underlying word ;

M: descriptive-error error.
    "The word " write dup word>> pprint " encountered an error." print
    "Arguments:" print
    dup args>> stack.
    "Error:" print
    underlying>> error. ;

<PRIVATE

: rethrower ( word inputs -- quot )
    [ length ] keep [ [ narray ] dip swap 2array flip ] 2curry
    [ 2 ndip descriptive-error ] 2curry ;

: [descriptive] ( word def effect -- newdef )
    swapd in>> rethrower [ recover ] 2curry ;

PRIVATE>

: make-descriptive ( word -- )
    dup [ ] [ def>> ] [ stack-effect ] tri [descriptive]
    '[ drop _ ] annotate ;

: define-descriptive ( word def effect -- )
    [ drop "descriptive-definition" set-word-prop ]
    [ [ [ dup ] 2dip [descriptive] ] keep define-declared ]
    3bi ;

SYNTAX: DESCRIPTIVE: (:) define-descriptive ;

PREDICATE: descriptive < word
    "descriptive-definition" word-prop >boolean ;

M: descriptive definer drop \ DESCRIPTIVE: \ ; ;

M: descriptive definition
    "descriptive-definition" word-prop ;

M: descriptive reset-word
    [ call-next-method ]
    [ "descriptive-definition" remove-word-prop ] bi ;

SYNTAX: DESCRIPTIVE:: (::) define-descriptive ;

PREDICATE: descriptive-lambda < descriptive lambda-word? ;

M: descriptive-lambda definer drop \ DESCRIPTIVE:: \ ; ;

M: descriptive-lambda definition
    "lambda" word-prop body>> ;

M: descriptive-lambda reset-word
    [ call-next-method ] [ "lambda" remove-word-prop ] bi ;
