! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators effects.parser
generalizations kernel sequences sequences.generalizations ;
IN: shuffle

MACRO: shuffle-effect ( effect -- quot )
    [ in>> H{ } zip-index-as ] [ out>> ] bi
    [ drop assoc-size '[ _ narray ] ]
    [ [ of '[ _ swap nth ] ] with map ] 2bi
    '[ @ _ cleave ] ;

SYNTAX: shuffle(
    ")" parse-effect suffix! \ shuffle-effect suffix! ;

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline

: 2pick ( x y z t -- x y z t x y ) reach reach ; inline

: 5roll ( a b c d e -- b c d e a ) [ roll ] dip swap ; inline

: 2reach ( w x y z -- w x y z w x ) reach reach ; inline

: nipdd ( w x y z -- x y z ) roll drop ; inline
