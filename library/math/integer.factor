! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: errors generic kernel math ;

DEFER: fixnum?
BUILTIN: fixnum 0 fixnum? ;
DEFER: bignum?
BUILTIN: bignum 1 bignum? ;
UNION: integer fixnum bignum ;

: (gcd) ( b a y x -- a d )
    dup 0 number= [
        drop nip
    ] [
        tuck /mod >r pick * swap >r swapd - r> r> (gcd)
    ] ifte ;

: gcd ( x y -- a d )
    #! Compute the greatest common divisor d and multiplier a
    #! such that a*x=d mod y.
    swap 0 1 2swap (gcd) abs ;

: mod-inv ( x n -- y )
    #! Compute the multiplicative inverse of x mod n.
    gcd 1 = [ "Non-trivial divisor found" throw ] unless ;

IN: math-internals

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
        2dup gcd nip tuck /i >r /i r> fraction>
    ] ifte ; inline

M: fixnum number=
    #! Fixnums are immediate values, so equality testing is
    #! trivial.
    eq? ;

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

M: integer truncate ;
M: integer floor ;
M: integer ceiling ;
