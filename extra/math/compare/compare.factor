! Copyright (C) 2008 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license
USING: math math.order kernel ;
IN: math.compare

: absmin ( a b -- x )
    [ [ abs ] bi@ < ] 2keep ? ;

: absmax ( a b -- x )
    [ [ abs ] bi@ > ] 2keep ? ;

: posmax ( a b -- x )
    0 max max ;

: negmin ( a b -- x )
    0 min min ;
