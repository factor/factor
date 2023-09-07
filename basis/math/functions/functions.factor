! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.bits math.constants
math.libm math.order sequences ;
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

M: float ^n (^n) ;

M: complex ^n (^n) ;

: integer^ ( x y -- z )
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

PRIVATE>

: ^ ( x y -- x^y )
    {
        { [ over zero? ] [ 0^ ] }
        { [ dup integer? ] [ integer^ ] }
        { [ 2dup real^? ] [ [ >float ] bi@ fpow ] }
        [ ^complex ]
    } cond ; inline

: nth-root ( n x -- y ) swap recip ^ ; inline

: divisor? ( m n -- ? )
    mod 0 = ; inline

ERROR: non-trivial-divisor n ;

: mod-inv ( x n -- y )
    [ nip ] [ gcd 1 = ] 2bi
    [ dup 0 < [ + ] [ nip ] if ]
    [ non-trivial-divisor ] if ; foldable

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
