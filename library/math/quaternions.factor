! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Everybody's favorite non-commutative skew field, the
! quaternions! Represented as pairs of complex numbers,
! that is, (a+bi)+(c+di)j.
USING: arrays kernel math sequences ;
IN: math-internals

: 2q [ first2 ] 2apply ;

: q*a 2q swapd ** >r * r> - ;

: q*b 2q >r ** swap r> * + ;

IN: math

: quaternion? ( seq -- ? )
    dup length 2 = [
        first2 [ number? ] 2apply and
    ] [
        2drop f
    ] if ;

: q* ( u v -- u*v ) [ q*a ] 2keep q*b 2array ;

: qconjugate ( u -- u' ) first2 neg >r conjugate r> 2array ;

: q/ ( u v -- u/v ) [ qconjugate q* ] keep norm-sq v/n ;

: q*n ( q n -- q )
    #! Note: you will get the wrong result if you try to
    #! multiply a quaternion by a complex number on the right
    #! using v*n. Use this word instead. Note that v*n with a
    #! quaternion and a real is okay.
    conjugate v*n ;

: c>q ( c -- q )
    #! Turn a complex number into a quaternion.
    0 2array ;

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
