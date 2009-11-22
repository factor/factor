! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.functions math.vectors sequences ;
IN: math.quaternions

! Everybody's favorite non-commutative skew field, the quaternions!

! Quaternions are represented as pairs of complex numbers, using the
! identity: (a+bi)+(c+di)j = a+bi+cj+dk.

<PRIVATE

: ** ( x y -- z ) conjugate * ; inline

: 2q ( u v -- u' u'' v' v'' ) [ first2 ] bi@ ; inline

: q*a ( u v -- a ) 2q swapd ** [ * ] dip - ; inline

: q*b ( u v -- b ) 2q [ ** swap ] dip * + ; inline

PRIVATE>

: q+ ( u v -- u+v )
    v+ ;

: q- ( u v -- u-v )
    v- ;

: q* ( u v -- u*v )
    [ q*a ] [ q*b ] 2bi 2array ;

: qconjugate ( u -- u' )
    first2 [ conjugate ] [ neg  ] bi* 2array ;

: qrecip ( u -- 1/u )
    qconjugate dup norm-sq v/n ;

: q/ ( u v -- u/v )
    qrecip q* ;

: q*n ( q n -- q )
    conjugate v*n ;

: c>q ( c -- q )
    0 2array ;

: v>q ( v -- q )
    first3 rect> [ 0 swap rect> ] dip 2array ;

: q>v ( q -- v )
    first2 [ imaginary-part ] dip >rect 3array ;

! Zero
CONSTANT: q0 { 0 0 }

! Units
CONSTANT: q1 { 1 0 }
CONSTANT: qi { C{ 0 1 } 0 }
CONSTANT: qj { 0 1 }
CONSTANT: qk { 0 C{ 0 1 } }

! Euler angles

<PRIVATE

: (euler) ( theta unit -- q )
    [ -0.5 * [ cos c>q ] [ sin ] bi ] dip n*v v- ;

PRIVATE>

: euler ( phi theta psi -- q )
  [ qi (euler) ] [ qj (euler) ] [ qk (euler) ] tri* q* q* ;
