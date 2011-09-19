! (c) 2011 Joe Groff bsd license
USING: combinators compiler.units fry generalizations kernel
locals macros math quotations sequences sequences.generalizations
slots vectors ;
IN: slots.macros

! Fundamental accessors

<PRIVATE
: define-slot ( name -- )
    [ define-protocol-slot ] with-compilation-unit ;
PRIVATE>

MACRO: slot ( name -- quot: ( tuple -- value ) )
    [ define-slot ] [ reader-word 1quotation ] bi ;
MACRO: set-slot ( name -- quot: ( value tuple -- ) )
    [ define-slot ] [ writer-word 1quotation ] bi ;


! In-place modifiers akin to *-at or *-nth

: change-slot ( ..a tuple name quot: ( ..a old -- ..b new ) -- ..b )
    '[ slot @ ] [ set-slot ] 2bi ; inline

: inc-slot ( tuple name -- )
    [ 0 or 1 + ] change-slot ; inline

: slot+ ( value tuple name -- )
    [ 0 or + ] change-slot ; inline

: push-slot ( value tuple name -- )
    [ ?push ] change-slot ; inline

! Chainable setters

: set-slot* ( tuple value name -- tuple )
    [ swap ] dip '[ _ set-slot ] keep ; inline

: change-slot* ( tuple name quot: ( ..a old -- ..b new ) -- ..b tuple ) 
    '[ _ _ change-slot ] keep ; inline

! Multiple-slot accessors

MACRO: slots ( names -- quot: ( tuple -- values... ) )
    [ '[ _ slot ] ] { } map-as '[ _ cleave ] ;
MACRO: {slots} ( names -- quot: ( tuple -- {values} ) )
    dup length '[ _ slots _ narray ] ;

MACRO: set-slots ( names -- quot: ( values... tuple -- ) )
    [ [ '[ _ set-slot ] ] [ ] map-as ] [ length dup ] bi
    '[ @ _ cleave-curry _ spread* ] ;

MACRO: {set-slots} ( names -- quot: ( {values} tuple -- ) )
    [ length ] keep '[ [ _ firstn ] dip _ set-slots ] ;
