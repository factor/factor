! Copyright (C) 2008 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license
USING: math math.order kernel ;
IN: math.compare

: absmin ( a b -- x )
    [ [ abs ] bi@ < ] most ;

: absmax ( a b -- x )
    [ [ abs ] bi@ > ] most ;

: posmax ( a b -- x )
    0 max max ;

: negmin ( a b -- x )
    0 min min ;

: max-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ dupd max = ] curry most ; inline

: min-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ dupd min = ] curry most ; inline
