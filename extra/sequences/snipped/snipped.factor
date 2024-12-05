! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math math.order sequences ;
IN: sequences.snipped

TUPLE: snipped < sequence-view
{ from integer read-only }
{ length integer read-only } ;

:: <snipped> ( from to seq -- snipped )
    seq dup length :> n
    from to [ 0 n clamp ] bi@
    over - snipped boa ;

: <removed> ( i seq -- snipped )
    [ dup 1 + ] dip <snipped> ;

M: snipped length [ seq>> length ] [ length>> ] bi [-] ;

M: snipped virtual@
    [ [ from>> dupd >= ] keep [ length>> + ] curry when ]
    [ seq>> ] bi ;
