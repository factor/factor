! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators generalizations kernel math sequences ;
IN: stack-as-data

MACRO: stack-nth ( n -- quot )
    [ '[ 1 _ ndupd ] ]
    [ 1 + '[ _ nrot ] ] bi
    '[ @ @ ] ;

: stack-set-nth ( obj n -- quot )
    [ '[ drop _ ] ] dip ndip ; inline

: stack-exchange ( m n -- quot )
    [ [ stack-nth ] [ '[ _ stack-nth ] dip ] bi* ] 2keep
    swapd
    [ stack-set-nth ] 2dip stack-set-nth ;

: stack-filter ( n quot: ( obj -- ? ) -- quot' )
    selector [ '[ _ ] replicate spread ] dip ; inline

: stack-map ( n quot: ( obj -- obj' ) -- quot' )
    '[ _ ] replicate spread ; inline
