! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
BUILTIN: fixnum 0 ;
BUILTIN: bignum 1 ;
UNION: integer fixnum bignum ;

IN: math-internals
USING: errors generic kernel math ;

: fraction> ( a b -- a/b )
    dup 1 number= [
        drop
    ] [
        (fraction>)
    ] ifte ;

: division-by-zero ( x y -- )
    "Division by zero" throw drop ;

: integer/ ( x y -- x/y )
    dup 0 number= [
        division-by-zero
    ] [
        dup 0 < [
            swap neg swap neg
        ] when
        2dup gcd tuck /i >r /i r> fraction>
    ] ifte ; inline

M: fixnum number= fixnum= ;
M: fixnum < fixnum< ;
M: fixnum <= fixnum<= ;
M: fixnum > fixnum> ;
M: fixnum >= fixnum>= ;

M: fixnum + fixnum+ ;
M: fixnum - fixnum- ;
M: fixnum * fixnum* ;
M: fixnum / integer/ ;
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
M: bignum / integer/ ;
M: bignum /i bignum/i ;
M: bignum /f bignum/f ;
M: bignum mod bignum-mod ;

M: bignum /mod bignum/mod ;

M: bignum bitand bignum-bitand ;
M: bignum bitor bignum-bitor ;
M: bignum bitxor bignum-bitxor ;
M: bignum shift bignum-shift ;

M: bignum bitnot bignum-bitnot ;
