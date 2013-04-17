! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors kernel math math.order sequences ;
IN: sequences.snipped

TUPLE: snipped
{ seq sequence read-only }
{ from integer read-only }
{ length integer read-only } ;

: <snipped> ( from to seq -- snipped )
    [ length min ] keep -rot over - snipped boa ;

: <removed> ( i seq -- snipped )
    [ dup 1 + ] dip <snipped> ;

M: snipped length [ seq>> length ] [ length>> ] bi [-] ;

M: snipped virtual@
    [ [ from>> dupd >= ] keep [ length>> + ] curry when ]
    [ seq>> ] bi ;

M: snipped virtual-exemplar seq>> ;

INSTANCE: snipped virtual-sequence
