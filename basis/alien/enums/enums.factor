! (c)2010 Joe Groff bsd license
USING: accessors alien.c-types arrays combinators delegate fry
kernel quotations sequences words.symbol ;
IN: alien.enums

TUPLE: enum-c-type base-type members ;

CONSULT: c-type-protocol enum-c-type
    base-type>> ;

<PRIVATE
: map-to-case ( quot: ( x -- y ) -- case )
    { } map-as [ ] suffix ; inline
PRIVATE>

: enum-unboxer ( members -- quot )
    [ first2 '[ _ ] 2array ] map-to-case '[ _ case ] ;

: enum-boxer ( members -- quot )
    [ first2 swap '[ _ ] 2array ] map-to-case '[ _ case ] ;

M: enum-c-type c-type-boxed-class drop object ;
M: enum-c-type c-type-boxer-quot members>> enum-boxer ;
M: enum-c-type c-type-unboxer-quot members>> enum-unboxer ;
M: enum-c-type c-type-setter
    [ members>> enum-unboxer ] [ base-type>> c-type-setter ] bi
    '[ _ 2dip @ ] ;

C: <enum-c-type> enum-c-type

<PRIVATE

: define-enum-members ( member-names -- )
    [ first define-symbol ] each ;

PRIVATE>

: define-enum ( word base-type members -- )
    [ define-enum-members ] [ <enum-c-type> swap typedef ] bi ;

PREDICATE: enum-c-type-word < c-type-word
    "c-type" word-prop enum-c-type? ;
