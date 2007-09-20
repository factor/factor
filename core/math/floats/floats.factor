! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.private math.libm ;
IN: math.floats.private

M: fixnum >float fixnum>float ;
M: bignum >float bignum>float ;

M: real abs dup 0 < [ neg ] when ;
M: real absq sq ;

M: real hashcode* nip >fixnum ;
M: real <=> - ;

M: float zero? dup 0.0 float= swap -0.0 float= or ;

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

M: real sqrt
    >float dup 0.0 < [ neg fsqrt 0.0 swap rect> ] [ fsqrt ] if ;
