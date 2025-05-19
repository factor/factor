! Copyright (C) 2007 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators effects effects.parser
generalizations kernel sequences sequences.generalizations
stack-checker.backend stack-checker.known-words
stack-checker.values words ;
IN: shuffle

MACRO: shuffle-effect ( effect -- quot )
    [ in>> H{ } zip-index-as ] [ out>> ] bi
    [ drop assoc-size '[ _ narray ] ]
    [ [ of '[ _ swap nth ] ] with map ] 2bi
    '[ @ _ cleave ] ;

: infer-shuffle-effect ( -- )
    1 ensure-d first literal value>> add-effect-input infer-shuffle ;

\ shuffle-effect [ infer-shuffle-effect ] "special" set-word-prop

SYNTAX: shuffle( \ shuffle-effect parse-call-paren ;

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline

: 2pick ( x y z t -- x y z t x y ) reach reach ; inline

: 5roll ( a b c d e -- b c d e a ) [ roll ] dip swap ; inline

: 6roll ( a b c d e f -- b c d e f a ) [ roll ] 2dip rot ; inline

: 7roll ( a b c d e f g -- b c d e f g a ) [ roll ] 3dip roll ; inline

: 8roll ( a b c d e f g h -- b c d e f g h a ) [ roll ] 4dip 5roll ; inline

: 2reach ( v w x y z -- v w x y z v w ) 5 npick 5 npick ; inline

: dupdd ( x y z -- x x y z ) [ dupd ] dip ; inline

: nipdd ( w x y z -- x y z ) roll drop ; inline

: spind ( w x y z -- y x w z ) [ spin ] dip ; inline
