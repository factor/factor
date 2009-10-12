! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs colors colors.constants combinators
combinators.short-circuit hashtables io.styles kernel literals
namespaces sequences words words.symbol ;
IN: prettyprint.stylesheet

<PRIVATE

CONSTANT: dim-color COLOR: gray35

{ POSTPONE: USING: POSTPONE: USE: POSTPONE: IN: }
[
    { { foreground $ dim-color } }
    "word-style" set-word-prop
] each

PREDICATE: highlighted-word < word [ parsing-word? ] [ delimiter? ] bi or ;

PRIVATE>

GENERIC: word-style ( word -- style )

M: word word-style
    [ presented associate ]
    [ "word-style" word-prop >hashtable ] bi assoc-union ;

M: highlighted-word word-style
    call-next-method COLOR: DarkSlateGray foreground associate
    swap assoc-union ;

<PRIVATE

: colored-presentation-style ( obj color -- style )
    [ presented associate ] [ foreground associate ] bi* assoc-union ;

PRIVATE>

: string-style ( str -- style )
    COLOR: LightSalmon4 colored-presentation-style ;

: vocab-style ( vocab -- style )
    dim-color colored-presentation-style ;

: effect-style ( effect -- style )
    presented associate stack-effect-style get assoc-union ;
