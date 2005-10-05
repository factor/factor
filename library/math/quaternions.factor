! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Everybody's favorite non-commutative skew field, the
! quaternions! Represented as pairs of complex numbers,
! that is, (a+bi)+(c+di)j.
USING: arrays kernel math sequences ;
IN: math-internals

: 2q [ first2 ] 2apply ; inline

: q*a 2q swapd ** >r * r> - ; inline

: q*b 2q >r ** swap r> * + ; inline

IN: math

: quaternion? ( seq -- ? )
    dup length 2 = [
        first2 [ number? ] 2apply and
    ] [
        drop f
    ] if ;

: q* ( u v -- u*v )
    #! Multiply quaternions.
    [ q*a ] 2keep q*b 2array ;

: qconjugate ( u -- u' )
    #! Quaternion conjugate.
    first2 neg >r conjugate r> 2array ;

: q/ ( u v -- u/v )
    #! Divide quaternions.
    [ qconjugate q* ] keep norm-sq v/n ;

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
: q0 Q{ 0 0 0 0 }Q ;

! Units
: q1 Q{ 1 0 0 0 }Q ;
: qi Q{ 0 1 0 0 }Q ;
: qj Q{ 0 0 1 0 }Q ;
: qk Q{ 0 0 0 1 }Q ;

! Euler angles -- see
! http://www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/euleranglestoquaternions.html

: (euler) ( theta unit -- q )
    >r -0.5 * dup cos c>q swap sin r> n*q v- ;

: euler ( phi theta psi -- q )
    qk (euler) >r qj (euler) >r qi (euler) r> q* r> q* ;
