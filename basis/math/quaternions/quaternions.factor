! Copyright (C) 2005, 2010 Joe Groff, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators kernel math
math.libm math.order math.vectors sequences ;
IN: math.quaternions

: q+ ( u v -- u+v )
    v+ ; inline

: q- ( u v -- u-v )
    v- ; inline

<PRIVATE

GENERIC: (q*sign) ( q -- q' )
M: object (q*sign) { -1 1 1 1 } v* ; inline

PRIVATE>

: q* ( u v -- u*v )
    {
        [ [ { 1 0 0 0 } vshuffle ] [ { 1 1 2 3 } vshuffle ] bi* v*    ]
        [ [ { 2 1 2 3 } vshuffle ] [ { 2 0 0 0 } vshuffle ] bi* v* v+ ]
        [ [ { 3 2 3 1 } vshuffle ] [ { 3 3 1 2 } vshuffle ] bi* v* v+ ]
        [ [ { 0 3 1 2 } vshuffle ] [ { 0 2 3 1 } vshuffle ] bi* v* v- ]
    } 2cleave (q*sign) ; inline

GENERIC: qconjugate ( u -- u' )
M: object qconjugate
    { 1 -1 -1 -1 } v* ; inline

: qrecip ( u -- 1/u )
    qconjugate dup norm-sq v/n ; inline

: q/ ( u v -- u/v )
    qrecip q* ; inline

: n*q ( n q -- r )
    n*v ; inline

: q*n ( q n -- r )
    v*n ; inline

: n>q ( n -- q )
    0 0 0 4array ; inline

: n>q-like ( c exemplar -- q )
    [ 0 0 0 ] dip 4sequence ; inline

: c>q ( c -- q )
    >rect 0 0 4array ; inline

: c>q-like ( c exemplar -- q )
    [ >rect 0 0 ] dip 4sequence ; inline

! Euler angles

<PRIVATE

: (euler) ( theta exemplar shuffle -- q )
    swap
    [ 0.5 * [ fcos ] [ fsin ] bi 0.0 0.0 ] [ call ] [ 4sequence ] tri* ; inline

PRIVATE>

: euler-like ( phi theta psi exemplar -- q )
    [ [ ] (euler) ] [ [ swapd ] (euler) ] [ [ rot ] (euler) ] tri-curry tri* q* q* ; inline

: euler ( phi theta psi -- q )
    { } euler-like ; inline

:: slerp ( q0 q1 t -- qt )
    q0 q1 vdot -1.0 1.0 clamp :> dot
    dot facos t * :> omega
    q1 dot q0 n*v v- normalize :> qt'
    omega fcos q0 n*v omega fsin qt' n*v v+ ; inline
