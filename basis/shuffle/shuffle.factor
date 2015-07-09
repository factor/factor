! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators effects.parser fry
generalizations kernel macros make sequences
sequences.generalizations ;
IN: shuffle

MACRO: shuffle-effect ( effect -- )
    [ in>> H{ } zip-index-as ] [ out>> ] bi
    [ drop assoc-size '[ _ narray ] ]
    [ [ of '[ _ swap nth ] ] with map ] 2bi
    '[ @ _ cleave ] ;

SYNTAX: shuffle(
    ")" parse-effect suffix! \ shuffle-effect suffix! ;

: tuck ( x y -- y x y ) swap over ; inline deprecated

: spin ( x y z -- z y x ) swap rot ; inline deprecated

: roll ( x y z t -- y z t x ) [ rot ] dip swap ; inline deprecated

: -roll ( x y z t -- t x y z ) swap [ -rot ] dip ; inline deprecated

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline
