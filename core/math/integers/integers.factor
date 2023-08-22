! Copyright (C) 2004, 2010 Slava Pestov.
! Copyright (C) 2008, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel kernel.private math math.order
math.private ;
IN: math.integers

<PRIVATE

: fixnum-min ( x y -- z ) [ fixnum< ] most ; foldable
: fixnum-max ( x y -- z ) [ fixnum> ] most ; foldable

M: integer numerator ; inline
M: integer denominator drop 1 ; inline
M: integer >fraction 1 ; inline

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

: fixnum-bit? ( x n -- ? )
    { fixnum fixnum } declare
    dup 0 >= [ neg shift even? not ] [ 2drop f ] if ;

M: fixnum bit? integer>fixnum-strict fixnum-bit? ; inline

: fixnum-log2 ( x -- n )
    { fixnum } declare
    0 swap [ dup 1 eq? ] [
        [ 1 fixnum+fast ] [ 2/ ] bi*
    ] until drop ;

M: fixnum (log2) fixnum-log2 { fixnum } declare ; inline

M: bignum >fixnum bignum>fixnum ; inline
M: bignum >bignum ; inline
M: bignum integer>fixnum bignum>fixnum ; inline
M: bignum integer>fixnum-strict bignum>fixnum-strict ; inline

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
! As an optimization to minimize the size of the operands of the bignum
! divisions we will do, we start by stripping any trailing zeros from
! the denominator and move it into the scale factor.
! We want a 54 bit result, starting with leading 1, followed by
! the 52 bit mantissa and then a guard bit: 1mmmmmmmmmm...mmmmmmmmmmmg
! So we shift the numerator to get the result of the integer division
! "num/den" in the range ]2^54; 2^53]; Our shift is only a guess
! based on the magnitude of the inputs, so it
! will actually give results in the range ]2^55; 2^53].
! Note: epsilon is used for rounding in step 3.
: twos ( x -- y ) dup 1 - bitxor log2 ; inline

: scale-denonimator ( den -- scaled-den scale' )
    dup twos neg [ shift ] keep ; inline

: (epsilon?) ( num shift -- ? )
    dup neg? [ neg 2^ 1 - bitand zero? not ] [ 2drop f ] if ; inline

: scale-numerator ( num den -- epsilon? num' scale )
    over [ log2 ] bi@ - [
        54 + [ (epsilon?) ] [ shift ] 2bi
    ] keep ; inline

: pre-scale ( num den -- epsilon? num' den' scale )
    scale-denonimator [
        [ scale-numerator ] keep swap
    ] dip swap - ; inline

! Second step: compute mantissa
! "num/den" would be in the range ]2^55; 2^53]. After this step
! it will be in the range ]2^54; 2^53]. Compute "num/den" and the
! reminder used for rounding
! For subnormals, after we know the final value of the exponent,
! we shift the numerator again to get the correct precision.
! We do it before rounding so that subnormals are correctly rounded.
: (2/-with-epsilon) ( epsilon? num -- epsilon?' num' )
    [ 1 bitand zero? not or ] [ 2/ ] bi ; inline

: (shift-with-epsilon) ( epsilon? num den scale -- epsilon?' num' den scale )
    [
        nip 1021 +
        [ neg 2^ 1 - bitand zero? not or ] [ shift ] 2bi
    ] 2keep ; inline

: mantissa-and-guard ( epsilon? num den scale -- epsilon?' mantissa-and-guard rem scale' )
    2over /i log2 53 >
    [ [ (2/-with-epsilon) ] [ ] [ 1 + ] tri* ] when
    ! At this point, the scale value is the exponent minus 1.
    dup -1021 < [ (shift-with-epsilon) ] when
    [ /mod ] dip ; inline

! Third step: rounding
!
! if the guard bit is 0, round down
! else if the guard bit is 1 and (rem != 0 or epsilon is true), round up
! else break the tie by alternating rounding down or up to avoid accumulating errors
!
! The epsilon trick works because epsilon is true if numerator bits were discarded.
! Mathematically, (num+epsilon)/denom = (num/denum) + (epsilon/denom)
! We have actually computed the "num/denum" part and use the "epsilon/denom"
! to choose the correct rounding.
!
! Note that rounding down means doing nothing because we will
! discard the guard bit after this
: round-to-nearest ( epsilon? mantissa-and-guard rem -- mantissa-and-guard' )
    over odd?
    [
        zero? [
            dup 2 bitand zero? not rot or [ 1 + ] when
        ] [ nip 1 + ] if
    ] [ drop nip ] if ; inline

! Fourth step: post-scaling
! Because of rounding, our mantissa with guard bit may have overflowed
! the 54 bit precision to 2^54 so we have to handle it specially.
! For subnormals, the rounding may also have overflowed the precision,
! but the overflowed value is actually the correct value by chance
! (even in the case when the biggest subnormal is rounded up to
! the smallest normal float) because we interpret it directly
! as the bits of the resulting double.
: scale-float ( mantissa scale -- float' )
    ! the scale value is the exponent minus 1.
    {
        { [ dup 1024 > ] [ 2drop 1/0. ] }
        { [ dup -1021 < ] [ drop bits>double ] } ! subnormals and underflow
        [ [ 52 2^ 1 - bitand ] dip 1022 + 52 shift bitor bits>double ]
    } cond ; inline

: post-scale ( mantissa scale -- n )
    [ 2/ ] dip ! drop guard bit
    over 53 2^ = [ [ 2/ ] [ 1 + ] bi* ] when
    scale-float ; inline

! Main word
: /f-abs ( m n -- f )
    over zero? [ nip zero? 0/0. 0.0 ? ] [
        [ drop 1/0. ] [
            pre-scale
            mantissa-and-guard
            [ round-to-nearest ] dip
            post-scale
        ] if-zero
    ] if ; inline

: bignum/f ( m n -- f )
    [ [ abs ] bi@ /f-abs ] [ [ 0 < ] bi@ xor ] 2bi [ neg ] when ; inline

M: bignum /f { bignum bignum } declare bignum/f ;

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

PRIVATE>
