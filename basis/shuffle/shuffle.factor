! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators effects.parser
generalizations sequences.generalizations hashtables kernel
locals locals.backend macros make math parser sequences ;
IN: shuffle

<PRIVATE

: >index-assoc ( sequence -- assoc )
    dup length iota zip >hashtable ;

PRIVATE>

MACRO: shuffle-effect ( effect -- )
    [ out>> ] [ in>> >index-assoc ] bi
    [
        [ nip assoc-size , \ narray , ]
        [ [ at \ swap \ nth [ ] 3sequence ] curry map , \ cleave , ] 2bi
    ] [ ] make ;

SYNTAX: shuffle(
    ")" parse-effect suffix! \ shuffle-effect suffix! ;

: tuck ( x y -- y x y ) swap over ; inline deprecated

: spin ( x y z -- z y x ) swap rot ; inline deprecated

: roll ( x y z t -- y z t x ) [ rot ] dip swap ; inline deprecated

: -roll ( x y z t -- t x y z ) swap [ -rot ] dip ; inline deprecated

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline

