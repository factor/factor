! Copyright (C) 2009 Keith Lazuka, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs colors io.styles kernel namespaces sequences words ;
IN: prettyprint.stylesheet

<PRIVATE

{ POSTPONE: USING: POSTPONE: USE: POSTPONE: IN: }
[
    { { foreground COLOR: gray35 } }
    "word-style" set-word-prop
] each

PREDICATE: highlighted-word < word [ parsing-word? ] [ delimiter? ] bi or ;

PRIVATE>

SYMBOL: base-word-style
H{ } base-word-style set-global

GENERIC: word-style ( word -- style )

M: word word-style
    [ presented base-word-style get clone [ set-at ] keep ]
    [ "word-style" word-prop ] bi assoc-union! ;

SYMBOL: highlighted-word-style
H{
    { foreground COLOR: DarkSlateGray }
} highlighted-word-style set-global

M: highlighted-word word-style
    call-next-method highlighted-word-style get assoc-union! ;

SYMBOL: base-string-style
H{
    { foreground COLOR: LightSalmon4 }
} base-string-style set-global

: string-style ( str -- style )
    presented base-string-style get clone [ set-at ] keep ;

SYMBOL: base-vocab-style
H{
    { foreground COLOR: gray35 }
} base-vocab-style set-global

: vocab-style ( vocab -- style )
    presented base-vocab-style get clone [ set-at ] keep ;

SYMBOL: base-effect-style
H{
    { foreground COLOR: FactorDarkSlateBlue }
    { font-style plain }
} base-effect-style set-global

: effect-style ( effect -- style )
    presented base-effect-style get clone [ set-at ] keep ;
