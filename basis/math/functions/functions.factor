! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel kernel.private math math.bits
math.constants math.libm math.order math.private sequences
sequences.private ;
IN: math.functions

GENERIC: sqrt ( x -- y ) foldable

M: real sqrt
    >float dup 0.0 <
    [ neg fsqrt [ 0.0 ] dip rect> ] [ fsqrt ] if ; inline

: factor-2s ( n -- r s )
    ! factor an integer into 2^r * s
    dup 0 = [ 1 ] [
        [ 0 ] dip [ dup even? ] [ [ 1 + ] [ 2/ ] bi* ] while
    ] if ; inline

<PRIVATE

: (^fixnum) ( z w -- z^w )
    [ 1 ] 2dip
    [ dup zero? ] [
        dup odd? [
            [ [ * ] keep ] [ 1 - ] bi*
        ] when [ sq ] [ 2/ ] bi*
    ] until 2drop ; inline

: (^bignum) ( z w -- z^w )
    make-bits 1 [ [ over * ] when [ sq ] dip ] reduce nip ; inline

: (^n) ( z w -- z^w )
    dup fixnum? [ (^fixnum) ] [ (^bignum) ] if ; inline

GENERIC#: ^n 1 ( z w -- z^w ) foldable

M: fixnum ^n (^n) ;

M: bignum ^n
    [ factor-2s ] dip [ (^n) ] keep rot * shift ;

M: ratio ^n
    [ >fraction ] dip '[ _ ^n ] bi@ / ;

M: float ^n [ >float fpow ] unless-zero ;

M: complex ^n (^n) ;

: ^integer ( x y -- z )
    dup 0 >= [ ^n ] [ [ recip ] dip neg ^n ] if ; inline

PRIVATE>

: >float-rect ( z -- x y )
    >rect [ >float ] bi@ ; inline

: >polar ( z -- abs arg )
    >float-rect [ [ sq ] bi@ + fsqrt ] [ swap fatan2 ] 2bi ; inline

: cis ( arg -- z ) >float [ fcos ] [ fsin ] bi rect> ; inline

: polar> ( abs arg -- z ) cis * ; inline

GENERIC: e^ ( x -- e^x )

M: float e^ fexp ; inline

M: real e^ >float e^ ; inline

M: complex e^ >rect [ e^ ] dip polar> ; inline

<PRIVATE

: ^mag ( w abs arg -- magnitude )
    [ >float-rect swap ]
    [ >float swap >float fpow ]
    [ rot * e^ /f ]
    tri* ; inline

: ^theta ( w abs arg -- theta )
    [ >float-rect ] [ flog * swap ] [ * + ] tri* ; inline

: ^complex ( x y -- z )
    swap >polar [ ^mag ] [ ^theta ] 3bi polar> ; inline

: real^? ( x y -- ? )
    2dup [ real? ] both? [ drop 0 >= ] [ 2drop f ] if ; inline

: 0^ ( zero x -- z )
    swap [ 0/0. ] swap '[ 0 < 1/0. _ ? ] if-zero ; inline

: (^mod) ( x y n -- z )
    [ make-bits 1 ] dip dup
    '[ [ over * _ mod ] when [ sq _ mod ] dip ] reduce nip ; inline

: >minimum-mod ( x n -- y ) 2dup 2/ > [ - ] [ drop ] if ; foldable

: >positive-mod ( x n -- y ) over 0 < [ + ] [ drop ] if ; foldable

PRIVATE>

: ^ ( x y -- x^y )
    {
        { [ over zero? ] [ 0^ ] }
        { [ dup integer? ] [ ^integer ] }
        { [ 2dup real^? ] [ [ >float ] bi@ fpow ] }
        [ ^complex ]
    } cond ; inline

: nth-root ( n x -- y ) swap recip ^ ; inline

: divisor? ( m n -- ? ) mod zero? ; inline

ERROR: non-trivial-divisor n ;

: mod-inv ( x n -- y )
    [ gcd 1 = ] 1check
    [ >positive-mod ] [ non-trivial-divisor ] if ; foldable

: ^mod ( x y n -- z )
    over 0 <
    [ [ [ neg ] dip ^mod ] keep mod-inv ] [ (^mod) ] if ; foldable

GENERIC: absq ( x -- y ) foldable

M: real absq sq ; inline

: ~abs ( x y epsilon -- ? )
    [ - abs ] dip < ;

: ~rel ( x y epsilon -- ? )
    [ [ - abs ] 2keep [ abs ] bi@ + ] dip * <= ;

: ~ ( x y epsilon -- ? )
    {
        { [ dup zero? ] [ drop number= ] }
        { [ dup 0 < ] [ neg ~rel ] }
        [ ~abs ]
    } cond ;

: conjugate ( z -- z* ) >rect neg rect> ; inline

: arg ( z -- arg ) >float-rect swap fatan2 ; inline

: [-1,1]? ( x -- ? )
    dup complex? [ drop f ] [ abs 1 <= ] if ; inline

: >=1? ( x -- ? )
    dup complex? [ drop f ] [ 1 >= ] if ; inline

GENERIC: frexp ( x -- y exp )

M: float frexp
    dup fp-special? [ dup zero? ] unless* [ 0 ] [
        double>bits
        [ 0x800f,ffff,ffff,ffff bitand 0.5 double>bits bitor bits>double ]
        [ -52 shift 0x7ff bitand 1022 - ] bi
    ] if ; inline

M: integer frexp
    [ 0.0 0 ] [
        dup 0 > [ 1 ] [ abs -1 ] if swap dup log2 [
            52 swap - shift 0x000f,ffff,ffff,ffff bitand
            0.5 double>bits bitor bits>double
        ] [ 1 + ] bi [ * ] dip
    ] if-zero ; inline

: fma ( x y z -- result ) [ >float ] tri@ ffma ;

DEFER: copysign

GENERIC#: ldexp 1 ( x exp -- y )

M: float ldexp
    over fp-special? [ over zero? ] unless* [ drop ] [
        [ double>bits dup -52 shift 0x7ff bitand 1023 - ] dip +
        {
            { [ dup -1074 < ] [ drop 0 copysign ] }
            { [ dup 1023 > ] [ drop 0 < -1/0. 1/0. ? ] }
            [
                dup -1022 < [ 52 + -52 2^ ] [ 1 ] if
                [ -0x7ff0,0000,0000,0001 bitand ]
                [ 1023 + 52 shift bitor bits>double ]
                [ * ] tri*
            ]
        } cond
    ] if ;

M: integer ldexp
    2dup [ zero? ] either? [ 2drop 0 ] [ shift ] if ;

GENERIC: log ( x -- y )

M: float log dup 0.0 >= [ flog ] [ 0.0 rect> log ] if ; inline

M: real log >float log ; inline

M: complex log >polar [ flog ] dip rect> ; inline

: logn ( x n -- y ) [ log ] bi@ / ;

GENERIC: lgamma ( x -- y )

M: float lgamma flgamma ;

M: real lgamma >float lgamma ;

<PRIVATE

: most-negative-finite-float ( -- x )
    -0x1.ffff,ffff,ffff,fp1023 >integer ; inline

: most-positive-finite-float ( -- x )
    0x1.ffff,ffff,ffff,fp1023 >integer ; inline

CONSTANT: log-2   0x1.62e42fefa39efp-1
CONSTANT: log10-2 0x1.34413509f79ffp-2

: representable-as-float? ( x -- ? )
    most-negative-finite-float
    most-positive-finite-float between? ; inline

: (bignum-log) ( n log-quot: ( x -- y ) log-2 -- log )
    dupd '[
        dup representable-as-float?
        [ >float @ ] [ frexp _ [ _ * ] bi* + ] if
    ] call ; inline

PRIVATE>

M: bignum log [ log ] log-2 (bignum-log) ;

GENERIC: log1+ ( x -- y )

M: object log1+ 1 + log ; inline

M: float log1+ dup -1.0 >= [ flog1+ ] [ 1.0 + 0.0 rect> log ] if ; inline

: 10^ ( x -- 10^x ) 10 swap ^ ; inline

GENERIC: log10 ( x -- y ) foldable

M: real log10 >float flog10 ; inline

M: complex log10 log 10 log / ; inline

M: bignum log10 [ log10 ] log10-2 (bignum-log) ;

GENERIC: e^-1 ( x -- e^x-1 )

M: float e^-1
    dup abs 0.7 < [
        dup e^ dup 1.0 = [
            drop
        ] [
            [ 1.0 - * ] [ log / ] bi
        ] if
    ] [ e^ 1.0 - ] if ; inline

M: real e^-1 >float e^-1 ; inline

GENERIC: cos ( x -- y ) foldable

M: complex cos
    >float-rect
    [ [ fcos ] [ fcosh ] bi* * ]
    [ [ fsin neg ] [ fsinh ] bi* * ] 2bi rect> ;

M: float cos fcos ; inline

M: real cos >float cos ; inline

: sec ( x -- y ) cos recip ; inline

GENERIC: cosh ( x -- y ) foldable

M: complex cosh
    >float-rect
    [ [ fcosh ] [ fcos ] bi* * ]
    [ [ fsinh ] [ fsin ] bi* * ] 2bi rect> ;

M: float cosh fcosh ; inline

M: real cosh >float cosh ; inline

: sech ( x -- y ) cosh recip ; inline

GENERIC: sin ( x -- y ) foldable

M: complex sin
    >float-rect
    [ [ fsin ] [ fcosh ] bi* * ]
    [ [ fcos ] [ fsinh ] bi* * ] 2bi rect> ;

M: float sin fsin ; inline

M: real sin >float sin ; inline

: cosec ( x -- y ) sin recip ; inline

GENERIC: sinh ( x -- y ) foldable

M: complex sinh
    >float-rect
    [ [ fsinh ] [ fcos ] bi* * ]
    [ [ fcosh ] [ fsin ] bi* * ] 2bi rect> ;

M: float sinh fsinh ; inline

M: real sinh >float sinh ; inline

: cosech ( x -- y ) sinh recip ; inline

GENERIC: tan ( x -- y ) foldable

M: complex tan [ sin ] [ cos ] bi / ;

M: float tan ftan ; inline

M: real tan >float tan ; inline

GENERIC: tanh ( x -- y ) foldable

M: complex tanh [ sinh ] [ cosh ] bi / ;

M: float tanh ftanh ; inline

M: real tanh >float tanh ; inline

: cot ( x -- y ) tan recip ; inline

: coth ( x -- y ) tanh recip ; inline

: acosh ( x -- y )
    dup sq 1 - sqrt + log ; inline

: asech ( x -- y ) recip acosh ; inline

: asinh ( x -- y )
    dup sq 1 + sqrt + log ; inline

: acosech ( x -- y ) recip asinh ; inline

: atanh ( x -- y )
    [ 1 + ] [ 1 - neg ] bi / log 2 / ; inline

: acoth ( x -- y ) recip atanh ; inline

: i* ( x -- y ) >rect neg swap rect> ;

: -i* ( x -- y ) >rect swap neg rect> ;

: asin ( x -- y )
    dup [-1,1]? [ >float fasin ] [ i* asinh -i* ] if ; inline

: acos ( x -- y )
    dup [-1,1]? [ >float facos ] [ asin pi 2 / swap - ] if ; inline

GENERIC: atan ( x -- y ) foldable

M: complex atan i* atanh i* ; inline

M: float atan fatan ; inline

M: real atan >float atan ; inline

: asec ( x -- y ) recip acos ; inline

: acosec ( x -- y ) recip asin ; inline

: acot ( x -- y ) recip atan ; inline

: deg>rad ( x -- y ) pi * 180 / ; inline

: rad>deg ( x -- y ) 180 * pi / ; inline

GENERIC: truncate ( x -- y )

M: real truncate dup 1 mod - ;

M: float truncate
    dup double>bits
    dup -52 shift 0x7ff bitand 0x3ff -
    ! check for floats without fractional part (>= 2^52)
    dup 52 < [
        nipd
        dup 0 < [
            ! the float is between -1.0 and 1.0,
            ! the result could be +/-0.0, but we will
            ! return 0.0 instead similar to other
            ! languages
            2drop 0.0 ! -63 shift zero? 0.0 -0.0 ?
        ] [
            ! Put zeroes in the correct part of the mantissa
            0x000fffffffffffff swap neg shift bitnot bitand
            bits>double
        ] if
    ] [
        ! check for nans and infinities and do an operation on them
        ! to trigger fp exceptions if necessary
        nip 0x400 = [ dup + ] when
    ] if ; inline

GENERIC: round ( x -- y )

GENERIC: round-to-even ( x -- y )

GENERIC: round-to-odd ( x -- y )

M: integer round ; inline

M: integer round-to-even ; inline

M: integer round-to-odd ; inline

: (round-tiebreak?) ( quotient rem denom tiebreak-quot -- q ? )
    [ [ > ] ] dip [ 2dip = and ] curry 3bi or ; inline

: (round-to-even?) ( quotient rem denom -- quotient ? )
    [ >integer odd? ] (round-tiebreak?) ; inline

: (round-to-odd?) ( quotient rem denom -- quotient ? )
    [ >integer even? ] (round-tiebreak?) ; inline

: (ratio-round) ( x round-quot -- y )
    [ >fraction [ /mod dup swapd abs 2 * ] keep ] [ call ] bi*
    [ swap 0 < -1 1 ? + ] [ nip ] if ; inline

: (float-round) ( x round-quot -- y )
    [ dup 1 mod [ - ] keep dup swapd abs 0.5 ] [ call ] bi*
    [ swap 0.0 < -1.0 1.0 ? + ] [ nip ] if ; inline

M: ratio round [ >= ] (ratio-round) ;

M: ratio round-to-even [ (round-to-even?) ] (ratio-round) ;

M: ratio round-to-odd [ (round-to-odd?) ] (ratio-round) ;

M: float round dup sgn 2 /f + truncate ;

M: float round-to-even [ (round-to-even?) ] (float-round) ;

M: float round-to-odd [ (round-to-odd?) ] (float-round) ;

: round-to-decimal ( x n -- y )
    10^ [ * round ] [ / ] bi ;

: round-to-step ( x step -- y )
    [ [ / round ] [ * ] bi ] unless-zero ;

: floor ( x -- y )
    dup 1 mod
    [ dup 0 < [ - 1 - ] [ - ] if ] unless-zero ; foldable

: ceiling ( x -- y ) neg floor neg ; foldable

: floor-to ( x step -- y )
    [ [ / floor ] [ * ] bi ] unless-zero ;

: lerp ( a b t -- a_t ) [ over - ] dip * + ; inline

: roots ( x t -- seq )
    [ [ log ] [ recip ] bi* * e^ ]
    [ recip 2pi * 0 swap complex boa e^ ]
    [ <iota> [ ^ * ] 2with map ] tri ;

! expit
: sigmoid ( x -- y ) neg e^ 1 + recip ; inline

: logit ( x -- y ) [ ] [ 1 swap - ] bi /f log ; inline


GENERIC: signum ( x -- y )

M: real signum sgn ;

M: complex signum dup abs / ;

MATH: copysign ( x y -- x' )

M: real copysign >float copysign ;

M: float copysign
    [ double>bits ] [ fp-sign ] bi*
    [ 63 2^ bitor ] [ 63 2^ bitnot bitand ] if
    bits>double ;

:: integer-sqrt ( x -- n )
    x [ 0 ] [
        assert-non-negative
        bit-length 1 - 2 /i :> c
        1 :> a!
        0 :> d!
        c bit-length <iota> <reversed> [| s |
            d :> e
            c s neg shift d!
            a d e - 1 - shift
            x 2 c * e - d - 1 + neg shift a /i + a!
        ] each
        a a sq x > [ 1 - ] when
    ] if-zero ;

<PRIVATE

GENERIC: (integer-log10) ( x -- n ) foldable

! For 32 bits systems, we could reduce
! this to the first 27 elements..
CONSTANT: log10-guesses {
    0 0 0 0 1 1 1 2 2 2 3 3 3 3
    4 4 4 5 5 5 6 6 6 6 7 7 7 8
    8 8 9 9 9 9 10 10 10 11 11 11
    12 12 12 12 13 13 13 14 14 14
    15 15 15 15 16 16 16 17 17
}

! This table will hold a few unused bignums on 32 bits systems...
! It could be reduced to the first 8 elements
! Note that even though the 64 bits most-positive-fixnum
! is hardcoded here this table also works (by chance) for 32bit systems.
! This is because there is only one power of 2 greater than the
! greatest power of 10 for 27 bit unsigned integers so we don't
! need to hardcode the 32 bits most-positive-fixnum. See the
! table below for powers of 2 and powers of 10 around the
! most-positive-fixnum.
!
! 67108864  2^26    | 72057594037927936   2^56
! 99999999  10^8    | 99999999999999999  10^17
! 134217727 2^27-1  | 144115188075855872  2^57
!                   | 288230376151711744  2^58
!                   | 576460752303423487  2^59-1
CONSTANT: log10-thresholds {
    9 99 999 9999 99999 999999
    9999999 99999999 999999999
    9999999999 99999999999
    999999999999 9999999999999
    99999999999999 999999999999999
    9999999999999999 99999999999999999
    576460752303423487
}

: fixnum-integer-log10 ( n -- x )
    dup (log2) { array-capacity } declare
    log10-guesses nth-unsafe { array-capacity } declare
    dup log10-thresholds nth-unsafe { fixnum } declare
    rot < [ 1 + ] when ; inline

! bignum-integer-log10-find-down and bignum-integer-log10-find-up
! work with very bad guesses, but in practice they will never loop
! more than once.
: bignum-integer-log10-find-down ( guess 10^guess n -- log10 )
    [ 2dup > ] [ [ [ 1 - ] [ 10 / ] bi* ] dip ] do while 2drop ;

: bignum-integer-log10-find-up ( guess 10^guess n -- log10 )
    [ 10 * ] dip
    [ 2dup <= ] [ [ [ 1 + ] [ 10 * ] bi* ] dip ] while 2drop ;

: bignum-integer-log10-guess ( n -- guess 10^guess )
    (log2) >integer log10-2 * >integer dup 10^ ;

: bignum-integer-log10 ( n -- x )
    [ bignum-integer-log10-guess ] keep 2dup >
    [ bignum-integer-log10-find-down ]
    [ bignum-integer-log10-find-up ] if ; inline

M: fixnum (integer-log10) fixnum-integer-log10 { fixnum } declare ; inline

M: bignum (integer-log10) bignum-integer-log10 ; inline

PRIVATE>

<PRIVATE

GENERIC: (integer-log2) ( x -- n ) foldable

M: integer (integer-log2) (log2) ; inline

: ((ratio-integer-log)) ( ratio quot -- log )
    [ >integer ] dip call ; inline

: (ratio-integer-log) ( ratio quot base -- log )
    pick 1 >=
    [ drop ((ratio-integer-log)) ] [
        [ recip ] 2dip
        [ drop ((ratio-integer-log)) ] [ nip pick ^ = ] 3bi
        [ 1 + ] unless neg
    ] if ; inline

M: ratio (integer-log2) [ (integer-log2) ] 2 (ratio-integer-log) ;

M: ratio (integer-log10) [ (integer-log10) ] 10 (ratio-integer-log) ;

PRIVATE>

: integer-log10 ( x -- n )
    assert-positive (integer-log10) ; inline

: integer-log2 ( x -- n )
    assert-positive (integer-log2) ; inline
