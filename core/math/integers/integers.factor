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
M: fixnum >float fixnum>float ; inline
M: fixnum integer>fixnum ; inline
M: fixnum integer>fixnum-strict ; inline

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

M: fixnum mod fixnum-mod ; inline

M: fixnum /mod fixnum/mod ; inline

M: fixnum bitand fixnum-bitand ; inline
M: fixnum bitor fixnum-bitor ; inline
M: fixnum bitxor fixnum-bitxor ; inline
M: fixnum shift integer>fixnum fixnum-shift ; inline

M: fixnum bitnot fixnum-bitnot ; inline

: fixnum-bit? ( n m -- b )
    neg shift 1 bitand zero? not ; inline

M: fixnum bit? fixnum-bit? ; inline

: fixnum-log2 ( x -- n )
    0 swap [ dup 1 eq? ] [ [ 1 + ] [ 2/ ] bi* ] until drop ;

M: fixnum (log2) fixnum-log2 ; inline

M: bignum >fixnum bignum>fixnum ; inline
M: bignum >bignum ; inline
M: bignum integer>fixnum bignum>fixnum ; inline

M: bignum integer>fixnum-strict
    dup bignum>fixnum
    2dup number= [ nip ] [ drop out-of-fixnum-range ] if ; inline

M: bignum hashcode* nip bignum>fixnum ;

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
M: bignum shift integer>fixnum bignum-shift ; inline

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

: (epsilon?) ( num shift -- ? )
    dup neg? [ neg 2^ 1 - bitand zero? not ] [ 2drop f ] if ; inline

: pre-scale ( num den -- epsilon? mantissa den' scale )
    2dup [ log2 ] bi@ -
    [ neg 54 + [ (epsilon?) ] [ shift ] 2bi ]
    [ [ scale-denonimator ] dip + ] bi-curry bi* ; inline

! Second step: loop
: (2/-with-epsilon) ( epsilon? num -- epsilon?' num' )
    [ 1 bitand zero? not or ] [ 2/ ] bi ; inline

: /f-loop ( epsilon? mantissa den scale -- epsilon?' fraction-and-guard rem scale' )
    [ 2over /i log2 53 > ]
    [ [ (2/-with-epsilon) ] [ ] [ 1 + ] tri* ] while
    [ /mod ] dip ; inline

! Third step: post-scaling
: scale-float ( mantissa scale -- float' )
    {
        { [ dup 1024 > ] [ 2drop 1/0. ] }
        { [ dup -1023 < ] [ 1021 + shift bits>double ] }
        [ [ 52 2^ 1 - bitand ] dip 1022 + 52 shift bitor bits>double ]
    } cond ; inline

: post-scale ( mantissa scale -- n )
    [ 2/ ] dip over log2 52 > [ [ 2/ ] [ 1 + ] bi* ] when
    scale-float ; inline

: round-to-nearest ( epsilon? fraction-and-guard rem -- fraction-and-guard' )
    over odd?
    [
        zero? [
            dup 2 bitand zero? not rot or [ 1 + ] when
        ] [ nip 1 + ] if
    ] [ drop nip ] if ;
    inline

! Main word
: /f-abs ( m n -- f )
    over zero? [ nip zero? 0/0. 0.0 ? ] [
        [ drop 1/0. ] [
            pre-scale
            /f-loop
            [ round-to-nearest ] dip
            post-scale
        ] if-zero
    ] if ; inline

: bignum/f ( m n -- f )
    [ [ abs ] bi@ /f-abs ] [ [ 0 < ] bi@ xor ] 2bi [ neg ] when ; inline

M: bignum /f ( m n -- f ) { bignum bignum } declare bignum/f ;

CONSTANT: bignum/f-threshold 0x20,0000,0000,0000

: fixnum/f ( m n -- m/n )
    [ >float ] bi@ float/f ; inline

M: fixnum /f
    { fixnum fixnum } declare
    2dup [ abs bignum/f-threshold >= ] either?
    [ bignum/f ] [ fixnum/f ] if ; inline

: bignum>float ( bignum -- float )
    { bignum } declare 1 >bignum bignum/f ;

M: bignum >float bignum>float ; inline
