! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math-internals
USING: math kernel ;

: float= ( n n -- ? )
    #! The compiler replaces this with a better intrinsic.
    [ double>bits ] 2apply number= ; foldable

IN: math

UNION: real rational float ;

M: real abs dup 0 < [ neg ] when ;
M: real absq sq ;

M: real hashcode >fixnum ;
M: real <=> - ;

: fp-nan? ( float -- ? )
    double>bits -51 shift BIN: 111111111111 [ bitand ] keep
    number= ;

M: float zero?
    dup 0.0 float= swap -0.0 float= or ;

M: float >fixnum float>fixnum ;
M: float >bignum float>bignum ;
M: float >float ;

M: float < float< ;
M: float <= float<= ;
M: float > float> ;
M: float >= float>= ;
M: float number= float= ;

M: float + float+ ;
M: float - float- ;
M: float * float* ;
M: float / float/f ;
M: float mod float-mod ;

: /f  ( x y -- z ) >r >float r> >float float/f ; foldable

M: ratio >float >fraction /f ;
