! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math-internals
USING: math kernel ;

: float= ( n n -- )
    #! The compiler replaces this with a better intrinsic.
    [ double>bits ] 2apply number= ;

IN: math

UNION: real rational float ;

M: real abs dup 0 < [ neg ] when ;
M: real absq sq ;

M: real hashcode ( n -- n ) >fixnum ;
M: real <=> - ;

: fp-nan? ( float -- ? )
    double>bits -51 shift BIN: 111111111111 [ bitand ] keep = ;

M: float zero? ( float -- ? ) dup 0.0 = swap -0.0 = or ;

M: float < float< ;
M: float <= float<= ;
M: float > float> ;
M: float >= float>= ;
M: float number= float= ;

M: float + float+ ;
M: float - float- ;
M: float * float* ;
M: float / float/f ;
M: float /f float/f ;
M: float mod float-mod ;
