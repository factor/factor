! Copyright (C) 2004, 2008 Slava Pestov.
! Copyright (C) 2008, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences
sequences.private math math.private combinators ;
IN: math.integers.private

M: integer numerator ;
M: integer denominator drop 1 ;

M: fixnum >fixnum ;
M: fixnum >bignum fixnum>bignum ;
M: fixnum >integer ;

M: fixnum hashcode* nip ;
M: fixnum equal? over bignum? [ >bignum bignum= ] [ 2drop f ] if ;
M: fixnum number= eq? ;

M: fixnum < fixnum< ;
M: fixnum <= fixnum<= ;
M: fixnum > fixnum> ;
M: fixnum >= fixnum>= ;

M: fixnum + fixnum+ ;
M: fixnum - fixnum- ;
M: fixnum * fixnum* ;
M: fixnum /i fixnum/i ;
M: fixnum /f [ >float ] dip >float float/f ;

M: fixnum mod fixnum-mod ;

M: fixnum /mod fixnum/mod ;

M: fixnum bitand fixnum-bitand ;
M: fixnum bitor fixnum-bitor ;
M: fixnum bitxor fixnum-bitxor ;
M: fixnum shift >fixnum fixnum-shift ;

M: fixnum bitnot fixnum-bitnot ;

M: fixnum bit? neg shift 1 bitand 0 > ;

: fixnum-log2 ( x -- n )
    0 swap [ dup 1 eq? ] [ [ 1 + ] [ 2/ ] bi* ] until drop ;

M: fixnum (log2) fixnum-log2 ;

M: bignum >fixnum bignum>fixnum ;
M: bignum >bignum ;

M: bignum hashcode* nip >fixnum ;

M: bignum equal?
    over bignum? [ bignum= ] [
        swap dup fixnum? [ >bignum bignum= ] [ 2drop f ] if
    ] if ;

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
M: bignum shift >fixnum bignum-shift ;

M: bignum bitnot bignum-bitnot ;
M: bignum bit? bignum-bit? ;
M: bignum (log2) bignum-log2 ;

! Converting ratios to floats. Based on FLOAT-RATIO from
! sbcl/src/code/float.lisp, which has the following license:

! "The software is in the public domain and is
! provided with absolutely no warranty."

! First step: pre-scaling
: twos ( x -- y ) dup 1 - bitxor log2 ; inline

: scale-denonimator ( den -- scaled-den scale' )
    dup twos neg [ shift ] keep ; inline

: pre-scale ( num den -- scale shifted-num scaled-den )
    2dup [ log2 ] bi@ -
    [ neg 54 + shift ] [ [ scale-denonimator ] dip + ] bi-curry bi*
    -rot ; inline

! Second step: loop
: shift-mantissa ( scale mantissa -- scale' mantissa' )
    [ 1 + ] [ 2/ ] bi* ; inline

: /f-loop ( scale mantissa den -- scale' fraction-and-guard rem )
    [ 2dup /i log2 53 > ]
    [ [ shift-mantissa ] dip ]
    while /mod ; inline

! Third step: post-scaling
: unscaled-float ( mantissa -- n )
    52 2^ 1 - bitand 1022 52 shift bitor bits>double ; inline

: scale-float ( scale mantissa -- float' )
    [ dup 0 < [ neg 2^ recip ] [ 2^ ] if ] dip * ; inline

: post-scale ( scale mantissa -- n )
    2/ dup log2 52 > [ shift-mantissa ] when
    unscaled-float scale-float ; inline

! Main word
: /f-abs ( m n -- f )
    over zero? [
        2drop 0.0
    ] [
        dup zero? [
            2drop 1/0.
        ] [
            pre-scale
            /f-loop over odd?
            [ zero? [ 1 + ] unless ] [ drop ] if
            post-scale
        ] if
    ] if ; inline

M: bignum /f ( m n -- f )
    [ [ abs ] bi@ /f-abs ] [ [ 0 < ] bi@ xor ] 2bi [ neg ] when ;
