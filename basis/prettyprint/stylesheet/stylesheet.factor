! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: colors.constants combinators combinators.short-circuit
hashtables io.styles kernel namespaces sequences words
words.symbol ;
IN: prettyprint.stylesheet

<PRIVATE

CONSTANT: dim-color COLOR: cornsilk4

: dimly-lit-word? ( word -- ? )
    { POSTPONE: USING: POSTPONE: USE: POSTPONE: IN: } memq? ;

: parsing-word-color ( word -- color )
    dimly-lit-word? dim-color COLOR: DarkSlateGray ? ;

PRIVATE>

: word-style ( word -- style )
    dup "word-style" word-prop >hashtable [
        [
            [ presented set ] [
                {
                    { [ dup parsing-word? ] [ parsing-word-color ] }
                    { [ dup delimiter? ] [ drop COLOR: DarkSlateGray ] }
                    { [ dup symbol? ] [ drop COLOR: DarkSlateGray ] }
                    [ drop COLOR: black ]
                } cond foreground set
            ] bi
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