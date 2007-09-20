! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math.complex.private
USING: kernel kernel.private math math.private
math.libm math.functions ;

M: real real ;
M: real imaginary drop 0 ;

M: number equal? number= ;

M: complex absq >rect [ sq ] 2apply + ;

: 2>rect ( x y -- xr yr xi yi )
    [ [ real ] 2apply ] 2keep [ imaginary ] 2apply ; inline

M: complex number=
    2>rect number= [ number= ] [ 2drop f ] if ;

: *re ( x y -- xr*yr xi*ri ) 2>rect * >r * r> ; inline
: *im ( x y -- xi*yr xr*yi ) 2>rect >r * swap r> * ; inline

M: complex + 2>rect + >r + r> (rect>) ;
M: complex - 2>rect - >r - r> (rect>) ;
M: complex * 2dup *re - -rot *im + (rect>) ;

: complex/ ( x y -- r i m )
    dup absq >r 2dup *re + -rot *im - r> ; inline

M: complex / complex/ tuck / >r / r> (rect>) ;

M: complex abs absq >float fsqrt ;

M: complex sqrt >polar swap fsqrt swap 2.0 / polar> ;

M: complex hashcode* nip >rect >fixnum swap >fixnum bitxor ;
