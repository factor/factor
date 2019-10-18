! Copyright (C) 2013 Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators fry kernel macros quotations
sequences sequences.generalizations ;
IN: combinators.extras

: once ( quot -- ) call ; inline
: twice ( quot -- ) dup [ call ] dip call ; inline
: thrice ( quot -- ) dup dup [ call ] 2dip [ call ] dip call ; inline

MACRO: cond-case ( assoc -- )
    [
        dup callable? not [
            [ first [ dup ] prepose ]
            [ second [ drop ] prepose ] bi 2array
        ] when
    ] map [ cond ] curry ;

MACRO: cleave-array ( quots -- )
    [ '[ _ cleave ] ] [ length '[ _ narray ] ] bi compose ;
