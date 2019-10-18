! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! Everybody's favorite non-commutative skew field, the
! quaternions!

! Quaternions are represented as pairs of complex numbers,
! using the identity: (a+bi)+(c+di)j = a+bi+cj+dk.
USING: arrays kernel math math.vectors math.functions
arrays sequences ;
IN: math.quaternions

<PRIVATE

: ** conjugate * ; inline

: 2q ( u v -- u' u'' v' v'' ) [ first2 ] 2apply ; inline

: q*a ( u v -- a ) 2q swapd ** >r * r> - ; inline

: q*b ( u v -- b ) 2q >r ** swap r> * + ; inline

PRIVATE>

: q* ( u v -- u*v )
    #! Multiply quaternions.
    [ q*a ] 2keep q*b 2array ;

: qconjugate ( u -- u' )
    #! Quaternion conjugate.
    first2 neg >r conjugate r> 2array ;

: qrecip ( u -- 1/u )
    #! Quaternion inverse.
    qconjugate dup norm-sq v/n ;

: q/ ( u v -- u/v )
    #! Divide quaternions.
    qrecip q* ;

: q*n ( q n -- q )
    #! Note: you will get the wrong result if you try to
    #! multiply a quaternion by a complex number on the right
    #! using v*n. Use this word instead. Note that v*n with a
    #! quaternion and a real is okay.
    conjugate v*n ;

: c>q ( c -- q )
    #! Turn a complex number into a quaternion.
    0 2array ;

: v>q ( v -- q )
    #! Turn a 3-vector into a quaternion with real part 0.
    first3 rect> >r 0 swap rect> r> 2array ;

: q>v ( q -- v )
    #! Get the vector part of a quaternion, discarding the real
    #! part.
    first2 >r imaginary r> >rect 3array ;

! Zero
: q0 { 0 0 } ;

! Units
: q1 { 1 0 } ;
: qi { C{ 0 1 } 0 } ;
: qj { 0 1 } ;
: qk { 0 C{ 0 1 } } ;

! Euler angles -- see
! http://www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/euleranglestoquaternions.html

: (euler) ( theta unit -- q )
    >r -0.5 * dup cos c>q swap sin r> n*v v- ;

: euler ( phi theta psi -- q )
    qk (euler) >r qj (euler) >r qi (euler) r> q* r> q* ;

