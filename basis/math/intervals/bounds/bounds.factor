! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel locals math math.order ;
IN: math.intervals.bounds

SINGLETON: negative-infinity
SINGLETON: positive-infinity
SINGLETON: undefined-bound
UNION: infinite-bound negative-infinity positive-infinity ;

! IEEE infinity literals remain opaque on targets without floating point.
! Only interval endpoints translate them into ordered, symbolic bounds.
: normalize-bound ( n -- bound )
    floating-point-supported? [ ] [
        dup float? [
            dup double>bits {
                { 0xfff0000000000000 [ drop negative-infinity ] }
                { 0x7ff0000000000000 [ drop positive-infinity ] }
                [ drop ]
            } case
        ] when
    ] if ;

: negative-bound ( -- bound )
    floating-point-supported? [ -1/0. ] [ negative-infinity ] if ;

: positive-bound ( -- bound )
    floating-point-supported? [ 1/0. ] [ positive-infinity ] if ;

: valid-bound? ( n -- ? )
    normalize-bound dup rational? [ drop t ] [ infinite-bound? ] if ;

:: symbolic-compare ( a b -- ordering )
    {
        { [ a b eq? ] [ +eq+ ] }
        { [ a negative-infinity eq? b positive-infinity eq? or ] [ +lt+ ] }
        { [ a positive-infinity eq? b negative-infinity eq? or ] [ +gt+ ] }
        [ a b <=> ]
    } cond ;

: bound<=> ( a b -- ordering )
    floating-point-supported? [ <=> ]
    [ [ normalize-bound ] bi@ symbolic-compare ] if ;
: bound< ( a b -- ? ) bound<=> +lt+ eq? ;
: bound> ( a b -- ? ) bound<=> +gt+ eq? ;
: bound<= ( a b -- ? )
    floating-point-supported? [ <= ] [ bound> not ] if ;
: bound>= ( a b -- ? )
    floating-point-supported? [ >= ] [ bound< not ] if ;
: bound= ( a b -- ? )
    floating-point-supported? [ number= ] [ bound<=> +eq+ eq? ] if ;
: bound-min ( a b -- c )
    floating-point-supported? [ min ] [ [ bound< ] most ] if ;
: bound-max ( a b -- c )
    floating-point-supported? [ max ] [ [ bound> ] most ] if ;

: bound-neg ( a -- b )
    normalize-bound {
        { negative-infinity [ positive-infinity ] }
        { positive-infinity [ negative-infinity ] }
        [ neg ]
    } case ;
: bound-abs ( a -- b )
    normalize-bound dup infinite-bound? [ drop positive-infinity ] [ abs ] if ;

:: bound+ ( a b -- c )
    a normalize-bound :> x b normalize-bound :> y
    {
        { [ x infinite-bound? y infinite-bound? and ]
            [ x y eq? [ x ] [ undefined-bound ] if ] }
        { [ x infinite-bound? ] [ x ] }
        { [ y infinite-bound? ] [ y ] }
        [ x y + ]
    } cond ;
: bound- ( a b -- c ) bound-neg bound+ ;

:: signed-infinity ( a b -- c )
    a 0 bound< b 0 bound< xor
    [ negative-infinity ] [ positive-infinity ] if ;

:: bound* ( a b -- c )
    a normalize-bound :> x b normalize-bound :> y
    x infinite-bound? y infinite-bound? or [
        x 0 bound= y 0 bound= or [ undefined-bound ] [ x y signed-infinity ] if
    ] [ x y * ] if ;

:: bound/ ( a b -- c )
    a normalize-bound :> x b normalize-bound :> y
    {
        { [ x infinite-bound? y infinite-bound? and ] [ undefined-bound ] }
        { [ x infinite-bound? ] [ x y signed-infinity ] }
        { [ y infinite-bound? ] [ 0 ] }
        [ x y / ]
    } cond ;

: bound-nan? ( n -- ? )
    floating-point-supported? [ fp-nan? ] [ valid-bound? not ] if ;
