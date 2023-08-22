! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math math.order
sequences ;
IN: progress-bars

ERROR: invalid-percent x ;

: check-percent ( x -- x )
    dup 0 1 between? [ invalid-percent ] unless ;

ERROR: invalid-length x ;

: check-length ( x -- x )
    dup { [ 0 > ] [ integer? ] } 1&& [ invalid-length ] unless ;

: (make-progress-bar) ( percent len completed-ch pending-ch -- string )
    [ [ * >integer ] keep over - ] 2dip
    [ <repetition> ] bi-curry@ bi* "" append-as ;

: make-progress-bar ( percent length -- string )
    [ check-percent ] [ check-length ] bi*
    CHAR: = CHAR: - (make-progress-bar) ;
