! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: colors.constants combinators combinators.short-circuit
hashtables io.styles kernel namespaces sequences words
words.symbol ;
IN: prettyprint.stylesheet

<PRIVATE

CONSTANT: dim-color COLOR: gray35
CONSTANT: alt-color COLOR: DarkSlateGray

: dimly-lit-word? ( word -- ? )
    { POSTPONE: USING: POSTPONE: USE: POSTPONE: IN: } memq? ;

: parsing-or-delim-word? ( word -- ? )
    [ parsing-word? ] [ delimiter? ] bi or ;

: word-color ( word -- color )
    {
        { [ dup dimly-lit-word? ] [ drop dim-color ] }
        { [ dup parsing-or-delim-word? ] [ drop alt-color ] }
        [ drop COLOR: black ]
    } cond ;

PRIVATE>

: word-style ( word -- style )
    dup "word-style" word-prop >hashtable [
        [
            [ presented set ] [ word-color foreground set ] bi
        ] bind
    ] keep ;

: string-style ( str -- style )
    [
        presented set
        COLOR: LightSalmon4 foreground set
    ] H{ } make-assoc ;

: vocab-style ( vocab -- style )
    [
        presented set
        dim-color foreground set
    ] H{ } make-assoc ;

: effect-style ( effect -- style )
    [
        presented set
        COLOR: DarkGreen foreground set
    ] H{ } make-assoc ;