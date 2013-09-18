! Copyright (C) 2013 Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators combinators.smart fry generalizations
kernel macros math quotations sequences
sequences.generalizations ;
IN: combinators.extras

: once ( quot -- ) call ; inline
: twice ( quot -- ) dup [ call ] dip call ; inline
: thrice ( quot -- ) dup dup [ call ] 2dip [ call ] dip call ; inline
: forever ( quot -- ) [ t ] compose loop ; inline

MACRO: cond-case ( assoc -- )
    [
        dup callable? not [
            [ first [ dup ] prepose ]
            [ second [ drop ] prepose ] bi 2array
        ] when
    ] map [ cond ] curry ;

MACRO: cleave-array ( quots -- )
    [ '[ _ cleave ] ] [ length '[ _ narray ] ] bi compose ;

: 3bi* ( u v w x y z p q -- )
    [ 3dip ] dip call ; inline

: 3bi@ ( u v w x y z quot -- )
    dup 3bi* ; inline

: keepd ( ..a x y quot: ( ..a x y -- ..b ) -- ..b x )
    2keep drop ; inline

: plox ( ... x/f quot: ( ... x -- ... ) -- ... )
    dupd when ; inline

MACRO: smart-plox ( true -- )
    [ inputs [ 1 - [ and ] n*quot ] keep ] keep swap
    '[ _ _ [ _ ndrop f ] smart-if ] ;
