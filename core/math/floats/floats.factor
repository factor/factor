! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.private ;
IN: math.floats.private

M: fixnum >float fixnum>float ;
M: bignum >float bignum>float ;

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
M: float /f float/f ;
M: float mod float-mod ;

M: real abs dup 0 < [ neg ] when ;
