! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators generalizations kernel math sequences shuffle ;
IN: stack-as-data

MACRO: stack-nth ( n -- quot )
    [ '[ 1 _ ndupd ] ]
    [ 1 + '[ _ nrot ] ] bi
    '[ @ @ ] ;

MACRO: stack-set-nth ( obj n -- quot )
    '[ [ drop _ ] _ ndip ] ;

MACRO: stack-exchange ( m n -- quot )
    [ [ stack-nth ] [ '[ _ stack-nth ] dip ] bi* ] 2keep
    swapd
    '[ _ _ stack-set-nth _ _ stack-set-nth ] ;

MACRO: stack-map ( n quot: ( obj -- obj' ) -- quot' )
    '[ _ ] replicate '[ _ spread ] ;
