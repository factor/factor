! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.private ;
IN: math.floats.private

M: fixnum >float fixnum>float ; inline
M: bignum >float bignum>float ; inline

M: float >fixnum float>fixnum ; inline
M: float >bignum float>bignum ; inline
M: float >float ; inline

M: float hashcode* nip float>bits ; inline
M: float equal? over float? [ float= ] [ 2drop f ] if ; inline
M: float number= float= ; inline

M: float < float< ; inline
M: float <= float<= ; inline
M: float > float> ; inline
M: float >= float>= ; inline

M: float + float+ ; inline
M: float - float- ; inline
M: float * float* ; inline
M: float / float/f ; inline
M: float /f float/f ; inline
M: float /i float/f >integer ; inline
M: float mod float-mod ; inline

M: real abs dup 0 < [ neg ] when ; inline
