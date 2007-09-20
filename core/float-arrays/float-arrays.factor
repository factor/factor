! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: float-arrays
USING: kernel kernel.private alien sequences
sequences.private math math.private ;

<PRIVATE

: float-array@ swap >fixnum 8 fixnum*fast ; inline

PRIVATE>

M: float-array clone (clone) ;
M: float-array length array-capacity ;

M: float-array nth-unsafe
    float-array@ alien-double ;

M: float-array set-nth-unsafe
    >r >r >float r> r> float-array@ set-alien-double ;

: >float-array ( seq -- float-array ) F{ } clone-like ; inline

M: float-array like
    drop dup float-array? [ >float-array ] unless ;

M: float-array new drop 0.0 <float-array> ;

M: float-array equal?
    over float-array? [ sequence= ] [ 2drop f ] if ;

INSTANCE: float-array sequence

: 1float-array ( x -- array ) 1 swap <float-array> ; flushable

: 2float-array ( x y -- array ) F{ } 2sequence ; flushable

: 3float-array ( x y z -- array ) F{ } 3sequence ; flushable

: 4float-array ( w x y z -- array ) F{ } 4sequence ; flushable
