! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences
sequences.private math math.private combinators ;
IN: math.integers.private

M: integer numerator ;
M: integer denominator drop 1 ;

M: fixnum >fixnum ;
M: fixnum >bignum fixnum>bignum ;

M: fixnum number= eq? ;

M: fixnum < fixnum< ;
M: fixnum <= fixnum<= ;
M: fixnum > fixnum> ;
M: fixnum >= fixnum>= ;

M: fixnum + fixnum+ ;
M: fixnum - fixnum- ;
M: fixnum * fixnum* ;
M: fixnum /i fixnum/i ;
M: fixnum mod fixnum-mod ;

M: fixnum /mod fixnum/mod ;

M: fixnum bitand fixnum-bitand ;
M: fixnum bitor fixnum-bitor ;
M: fixnum bitxor fixnum-bitxor ;
M: fixnum shift >fixnum fixnum-shift ;

M: fixnum bitnot fixnum-bitnot ;

M: fixnum bit? 2^ bitand 0 > ;

: (fixnum-log2) ( accum n -- accum )
    dup 1 number= [ drop ] [ >r 1+ r> 2/ (fixnum-log2) ] if ;
    inline

M: fixnum (log2) 0 swap (fixnum-log2) ;

M: bignum >fixnum bignum>fixnum ;
M: bignum >bignum ;

M: bignum number= bignum= ;
M: bignum < bignum< ;
M: bignum <= bignum<= ;
M: bignum > bignum> ;
M: bignum >= bignum>= ;

M: bignum + bignum+ ;
M: bignum - bignum- ;
M: bignum * bignum* ;
M: bignum /i bignum/i ;
M: bignum mod bignum-mod ;

M: bignum /mod bignum/mod ;

M: bignum bitand bignum-bitand ;
M: bignum bitor bignum-bitor ;
M: bignum bitxor bignum-bitxor ;
M: bignum shift bignum-shift ;

M: bignum bitnot bignum-bitnot ;
M: bignum bit? bignum-bit? ;
M: bignum (log2) bignum-log2 ;

M: integer zero? 0 number= ;
