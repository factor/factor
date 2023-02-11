! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators grouping kernel math
math.combinatorics math.polynomials math.vectors sequences ;
IN: math.splines

<PRIVATE
:: bernstein-polynomial-ith ( n i -- p )
    n i nCk { 0 1 } i p^ { 1 -1 } n i - p^ p* n*p ;

:: hermite-polynomial ( p0 m0 p1 m1 -- poly )
    p0
    m0
    -3 p0 * -2 m0 * + 3 p1 * + m1 neg +
    2 p0 * m0 + -2 p1 * + m1 +
    4array ;

:: kochanek-bartels-coefficients ( tension bias continuity -- s1 d1 s2 d2 )
    1 tension -
    [
        1 bias +
        [ 1 continuity + * * 2 / ]
        [ 1 continuity - * * 2 / ] 2bi
    ]
    [
        1 bias -
        [ 1 continuity - * * 2 / ]
        [ 1 continuity + * * 2 / ] 2bi
    ] bi ;

:: kochanek-bartels-tangents ( points m0 mn c1 c2 -- tangents )
    points 3 clump [
        first3 :> ( pi-1 pi pi+1 )
        pi pi-1 v- c1 v*n
        pi+1 pi v- c2 v*n v+
    ] map
    m0 prefix
    mn suffix ;
PRIVATE>

:: <bezier-curve> ( control-points -- polynomials )
    control-points
    [ length 1 - ]
    [ first length [ { 0 } ] replicate ]
    bi :> ( n acc )

    control-points [| pt i |
        n i bernstein-polynomial-ith :> poly
        pt [| v j |
            j acc [ v poly n*p p+ ] change-nth
        ] each-index
    ] each-index
    acc ;

:: <cubic-hermite-curve> ( p0 m0 p1 m1 -- polynomials )
    p0 length <iota> [
        {
            [ p0 nth ] [ m0 nth ]
            [ p1 nth ] [ m1 nth ]
        } cleave
        hermite-polynomial
    ] map ;

<PRIVATE
: (cubic-hermite-spline) ( point-in-out-triplets -- polynomials-sequence )
    2 clump [
        first2 [ first2 ] [ [ first ] [ third ] bi ] bi* <cubic-hermite-curve>
    ] map ;
PRIVATE>

: <cubic-hermite-spline> ( point-tangent-pairs -- polynomials-sequence )
    2 clump [ first2 [ first2 ] bi@ <cubic-hermite-curve> ] map ;

:: <kochanek-bartels-curve> ( points m0 mn tension bias continuity -- polynomials-sequence )
    tension bias continuity kochanek-bartels-coefficients :> ( s1 d1 s2 d2 )
    points m0 mn
    [ s1 s2 kochanek-bartels-tangents ]
    [ d1 d2 kochanek-bartels-tangents ] 3bi :> ( in out )
    points in out [ 3array ] 3map (cubic-hermite-spline) ;

: <catmull-rom-spline> ( points m0 mn -- polynomials-sequence )
    0 0 0 <kochanek-bartels-curve> ;
