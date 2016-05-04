! Copyright (C) 2009 Keith Lazuka, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs colors combinators
combinators.short-circuit hashtables io.styles kernel literals
namespaces sequences ui.gadgets.theme words words.symbol ;
IN: prettyprint.stylesheet

<PRIVATE

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
    [ "word-style" word-prop ] bi assoc-union!
    text-color foreground pick set-at ;

M: highlighted-word word-style
    call-next-method
    highlighted-word-color foreground pick set-at ;

<PRIVATE

: colored-presentation-style ( obj color -- style )
    2 <hashtable> [
        [ presented foreground ] dip
        [ set-at ] curry bi-curry@ bi*
    ] keep ;

PRIVATE>

: string-style ( str -- style )
    string-color colored-presentation-style ;

: vocab-style ( vocab -- style )
    dim-color colored-presentation-style ;

SYMBOL: stack-effect-style

H{
    { foreground $ stack-effect-color }
    { font-style plain }
} stack-effect-style set-global

: effect-style ( effect -- style )
    presented associate stack-effect-style get assoc-union! ;
