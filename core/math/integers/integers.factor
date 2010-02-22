! Copyright (C) 2004, 2010 Slava Pestov.
! Copyright (C) 2008, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences sequences.private math
math.private math.order combinators ;
IN: math.integers.private

: fixnum-min ( x y -- z ) [ fixnum< ] most ; foldable
: fixnum-max ( x y -- z ) [ fixnum> ] most ; foldable

M: integer numerator ; inline
M: integer denominator drop 1 ; inline

M: fixnum >fixnum ; inline
M: fixnum >bignum fixnum>bignum ; inline
M: fixnum >integer ; inline

M: fixnum hashcode* nip ; inline
M: fixnum equal? over bignum? [ >bignum bignum= ] [ 2drop f ] if ; inline
M: fixnum number= eq? ; inline

M: fixnum < fixnum< ; inline
M: fixnum <= fixnum<= ; inline
M: fixnum > fixnum> ; inline
M: fixnum >= fixnum>= ; inline

M: fixnum u< fixnum< ; inline
M: fixnum u<= fixnum<= ; inline
M: fixnum u> fixnum> ; inline
M: fixnum u>= fixnum>= ; inline

M: fixnum min over fixnum? [ fixnum-min ] [ call-next-method ] if ; inline
M: fixnum max over fixnum? [ fixnum-max ] [ call-next-method ] if ; inline

M: fixnum + fixnum+ ; inline
M: fixnum - fixnum- ; inline
M: fixnum * fixnum* ; inline
M: fixnum /i fixnum/i ; inline

DEFER: bignum/f
CONSTANT: bignum/f-threshold HEX: 20,0000,0000,0000

: fixnum/f ( m n -- m/n )
    [ >float ] bi@ float/f ; inline

M: fixnum /f
    2dup [ abs bignum/f-threshold >= ] either?
    [ bignum/f ] [ fixnum/f ] if ; inline

M: fixnum mod fixnum-mod ; inline

M: fixnum /mod fixnum/mod ; inline

M: fixnum bitand fixnum-bitand ; inline
M: fixnum bitor fixnum-bitor ; inline
M: fixnum bitxor fixnum-bitxor ; inline
M: fixnum shift >fixnum fixnum-shift ; inline

M: fixnum bitnot fixnum-bitnot ; inline

: fixnum-bit? ( n m -- b )
    neg shift 1 bitand 0 > ; inline

M: fixnum bit? fixnum-bit? ; inline

: fixnum-log2 ( x -- n )
    0 swap [ dup 1 eq? ] [ [ 1 + ] [ 2/ ] bi* ] until drop ;

M: fixnum (log2) fixnum-log2 ; inline

M: bignum >fixnum bignum>fixnum ; inline
M: bignum >bignum ; inline

M: bignum hashcode* nip >fixnum ;

M: bignum equal?
    over bignum? [ bignum= ] [
        swap dup fixnum? [ >bignum bignum= ] [ 2drop f ] if
    ] if ; inline

M: bignum number= bignum= ; inline

M: bignum < bignum< ; inline
M: bignum <= bignum<= ; inline
M: bignum > bignum> ; inline
M: bignum >= bignum>= ; inline

M: bignum u< bignum< ; inline
M: bignum u<= bignum<= ; inline
M: bignum u> bignum> ; inline
M: bignum u>= bignum>= ; inline

M: bignum + bignum+ ; inline
M: bignum - bignum- ; inline
M: bignum * bignum* ; inline
M: bignum /i bignum/i ; inline
M: bignum mod bignum-mod ; inline

M: bignum /mod bignum/mod ; inline

M: bignum bitand bignum-bitand ; inline
M: bignum bitor bignum-bitor ; inline
M: bignum bitxor bignum-bitxor ; inline
M: bignum shift >fixnum bignum-shift ; inline

M: bignum bitnot bignum-bitnot ; inline
M: bignum bit? bignum-bit? ; inline
M: bignum (log2) bignum-log2 ; inline

! Converting ratios to floats. Based on FLOAT-RATIO from
! sbcl/src/code/float.lisp, which has the following license:

! "The software is in the public domain and is
! provided with absolutely no warranty."

! First step: pre-scaling
: twos ( x -- y ) dup 1 - bitxor log2 ; inline

: scale-denonimator ( den -- scaled-den scale' )
    dup twos neg [ shift ] keep ; inline

: pre-scale ( num den -- mantissa den' scale )
    2dup [ log2 ] bi@ -
    [ neg 54 + shift ] [ [ scale-denonimator ] dip + ] bi-curry bi* ; inline

! Second step: loop
: /f-loop ( mantissa den scale -- fraction-and-guard rem scale' )
    [ 2over /i log2 53 > ]
    [ [ 2/ ] [ ] [ 1 + ] tri* ] while
    [ /mod ] dip ; inline

! Third step: post-scaling
: unscaled-float ( mantissa -- n )
    52 2^ 1 - bitand 1022 52 shift bitor bits>double ; inline

: scale-float ( mantissa scale -- float' )
    dup 0 < [ neg 2^ recip ] [ 2^ ] if * ; inline

: post-scale ( mantissa scale -- n )
    [ 2/ ] dip over log2 52 > [ [ 2/ ] [ 1 + ] bi* ] when
    [ unscaled-float ] dip scale-float ; inline

! Main word
: /f-abs ( m n -- f )
    over zero? [
        2drop 0.0
    ] [
        [
            drop 1/0.
        ] [
            pre-scale
            /f-loop
            [ over odd? [ zero? [ 1 + ] unless ] [ drop ] if ] dip
            post-scale
        ] if-zero
    ] if ; inline

: bignum/f ( m n -- f )
    [ [ abs ] bi@ /f-abs ] [ [ 0 < ] bi@ xor ] 2bi [ neg ] when ;

M: bignum /f ( m n -- f )
    bignum/f ;
