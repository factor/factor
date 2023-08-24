! Copyright (C) 2010 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license

USING: combinators kernel math ;

IN: math.approx

<PRIVATE

:: (simplest) ( n d n' d' -- val ) ! assumes 0 < n/d < n'/d'
    n  d  /mod :> ( q  r  )
    n' d' /mod :> ( q' r' )
    {
        { [ r zero? ] [ q ] }
        { [ q q' = not ] [ q 1 + ] }
        [
            d' r' d r (simplest) >fraction :> ( n'' d'' )
            q n'' * d'' + n'' /
        ]
    } cond ;

:: simplest ( x y -- val )
    {
        { [ x y > ] [ y x simplest ] }
        { [ x y = ] [ x ] }
        { [ x 0 > ] [ x y [ >fraction ] bi@ (simplest) ] }
        { [ y 0 < ] [ y x [ neg >fraction ] bi@ (simplest) neg ] }
        [ 0 ]
    } cond ;

: check-float ( x -- x )
    dup float? [ "can't be floats" throw ] when ;

PRIVATE>

: approximate ( x epsilon -- y )
    [ check-float ] bi@ [ - ] [ + ] 2bi simplest ;
