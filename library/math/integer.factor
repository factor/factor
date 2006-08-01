! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: errors generic kernel kernel-internals sequences
sequences-internals ;

UNION: integer fixnum bignum ;

: even? ( n -- ? ) 1 bitand 0 = ;

: odd? ( n -- ? ) 1 bitand 1 = ;

: (gcd) ( b a y x -- a d )
    dup zero? [
        drop nip
    ] [
        tuck /mod >r pick * swap >r swapd - r> r> (gcd)
    ] if ; inline

: gcd ( x y -- a d ) 0 1 2swap (gcd) abs ; foldable

: (next-power-of-2) ( i n -- n )
    2dup >= [
        drop
    ] [
        >r 1 shift r> (next-power-of-2)
    ] if ;

: next-power-of-2 ( n -- n ) 2 swap (next-power-of-2) ;

IN: math-internals

: fraction> ( a b -- a/b )
    dup 1 number= [ drop ] [ (fraction>) ] if ; inline

TUPLE: /0 ;
: /0 ( -- ) </0> throw ;

M: integer / ( x y -- x/y )
    dup zero? [
        /0
    ] [
        dup 0 < [ [ neg ] 2apply ] when
        2dup gcd nip tuck /i >r /i r> fraction>
    ] if ;

M: fixnum number= eq? ;

M: fixnum < fixnum< ;
M: fixnum <= fixnum<= ;
M: fixnum > fixnum> ;
M: fixnum >= fixnum>= ;

M: fixnum + fixnum+ ;
M: fixnum - fixnum- ;
M: fixnum * fixnum* ;
M: fixnum /i fixnum/i ;
M: fixnum /f fixnum/f ;
M: fixnum mod fixnum-mod ;

M: fixnum /mod fixnum/mod ;

M: fixnum bitand fixnum-bitand ;
M: fixnum bitor fixnum-bitor ;
M: fixnum bitxor fixnum-bitxor ;
M: fixnum shift fixnum-shift ;

M: fixnum bitnot fixnum-bitnot ;

M: bignum number= bignum= ;
M: bignum < bignum< ;
M: bignum <= bignum<= ;
M: bignum > bignum> ;
M: bignum >= bignum>= ;

M: bignum + bignum+ ;
M: bignum - bignum- ;
M: bignum * bignum* ;
M: bignum /i bignum/i ;
M: bignum /f bignum/f ;
M: bignum mod bignum-mod ;

M: bignum /mod bignum/mod ;

M: bignum bitand bignum-bitand ;
M: bignum bitor bignum-bitor ;
M: bignum bitxor bignum-bitxor ;
M: bignum shift bignum-shift ;

M: bignum bitnot bignum-bitnot ;

M: integer zero? 0 number= ;
