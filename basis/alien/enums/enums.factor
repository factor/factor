! (c)2010 Joe Groff, Erik Charlebois bsd license
USING: accessors alien.c-types arrays combinators delegate fry
generic.parser kernel macros math parser sequences words words.symbol
classes.singleton assocs ;
IN: alien.enums

<PRIVATE
TUPLE: enum-c-type base-type members ;
C: <enum-c-type> enum-c-type
CONSULT: c-type-protocol enum-c-type
    base-type>> ;
PRIVATE>

GENERIC: enum>number ( enum -- number ) foldable
M: integer enum>number ;
M: word enum>number "enum-value" word-prop ;

<PRIVATE
: enum-boxer ( members -- quot )
    [ first2 swap '[ _ ] 2array ]
    { } map-as [ ] suffix '[ _ case ] ;
PRIVATE>

MACRO: number>enum ( enum-c-type -- )
    c-type members>> enum-boxer ;

M: enum-c-type c-type-boxed-class drop object ;
M: enum-c-type c-type-boxer-quot members>> enum-boxer ;
M: enum-c-type c-type-unboxer-quot drop [ enum>number ] ;
M: enum-c-type c-type-setter
   [ enum>number ] swap base-type>> c-type-setter '[ _ 2dip @ ] ;

: define-enum-value ( class value -- )
    enum>number "enum-value" set-word-prop ;

<PRIVATE

: define-enum-members ( members -- )
    [ first define-singleton-class ] each ;

: define-enum-constructor ( word -- )
    [ name>> "<" ">" surround create-in ] keep
    [ number>enum ] curry ( number -- enum ) define-inline ;

PRIVATE>

: (define-enum) ( word base-type members -- )
    [ dup define-enum-constructor ] 2dip
    [ define-enum-members ]
    [ <enum-c-type> swap typedef ] bi ;

: define-enum ( word base-type members -- )
    [ (define-enum) ]
    [ [ define-enum-value ] assoc-each ] bi ;
    
PREDICATE: enum-c-type-word < c-type-word
    "c-type" word-prop enum-c-type? ;
