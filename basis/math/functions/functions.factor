! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel math.constants math.private math.bits
math.libm combinators fry math.order sequences ;
IN: math.functions

: >fraction ( a/b -- a b )
    [ numerator ] [ denominator ] bi ; inline

: rect> ( x y -- z )
    [ complex boa ] unless-zero ; inline

GENERIC: sqrt ( x -- y ) foldable

M: real sqrt
    >float dup 0.0 <
    [ neg fsqrt [ 0.0 ] dip rect> ] [ fsqrt ] if ; inline

: factor-2s ( n -- r s )
    #! factor an integer into 2^r * s
    dup 0 = [ 1 ] [
        [ 0 ] dip [ dup even? ] [ [ 1 + ] [ 2/ ] bi* ] while
    ] if ; inline

<PRIVATE

GENERIC# ^n 1 ( z w -- z^w ) foldable

: (^n) ( z w -- z^w )
    make-bits 1 [ [ over * ] when [ sq ] dip ] reduce nip ; inline

M: integer ^n
    [ factor-2s ] dip [ (^n) ] keep rot * shift ;

M: ratio ^n
    [ >fraction ] dip '[ _ ^n ] bi@ / ;

M: float ^n (^n) ;

M: complex ^n (^n) ;

: integer^ ( x y -- z )
    dup 0 >= [ ^n ] [ [ recip ] dip neg ^n ] if ; inline

PRIVATE>

: >rect ( z -- x y )
    [ real-part ] [ imaginary-part ] bi ; inline

: >float-rect ( z -- x y )
    >rect [ >float ] bi@ ; inline

: >polar ( z -- abs arg )
    >float-rect [ [ sq ] bi@ + fsqrt ] [ swap fatan2 ] 2bi ; inline

: cis ( arg -- z ) >float [ fcos ] [ fsin ] bi rect> ; inline

: polar> ( abs arg -- z ) cis * ; inline

GENERIC: e^ ( x -- y )

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

: (gcd) ( b a x y -- a d )
    over zero? [
        2nip
    ] [
        swap [ /mod [ over * swapd - ] dip ] keep (gcd)
    ] if ; inline recursive

PRIVATE>

: ^ ( x y -- z )
    {
        { [ over zero? ] [ 0^ ] }
        { [ dup integer? ] [ integer^ ] }
        { [ 2dup real^? ] [ [ >float ] bi@ fpow ] }
        [ ^complex ]
    } cond ; inline

: nth-root ( n x -- y ) swap recip ^ ; inline

: gcd ( x y -- a d )
    [ 0 1 ] 2dip (gcd) dup 0 < [ neg ] when ; inline

MATH: fast-gcd ( x y -- d ) foldable

<PRIVATE

: simple-gcd ( x y -- d ) gcd nip ; inline

PRIVATE>

M: real fast-gcd simple-gcd ; inline

M: bignum fast-gcd bignum-gcd ; inline

: lcm ( a b -- c )
    [ * ] 2keep fast-gcd /i ; foldable

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

GENERIC: log ( x -- y )

M: float log dup 0.0 >= [ flog ] [ 0.0 rect> log ] if ; inline

M: real log >float log ; inline

M: complex log >polar [ flog ] dip rect> ; inline

<PRIVATE

: most-negative-finite-float ( -- x )
    -0x1.ffff,ffff,ffff,fp1023 >integer ; inline
: most-positive-finite-float ( -- x )
    0x1.ffff,ffff,ffff,fp1023 >integer ; inline
CONSTANT: log-2   0x1.62e42fefa39efp-1
CONSTANT: log10-2 0x1.34413509f79ffp-2

: (representable-as-float?) ( x -- ? )
    most-negative-finite-float
    most-positive-finite-float between? ; inline

: (bignum-log) ( n log-quot: ( x -- y ) log-2 -- log )
    [ dup ] dip '[
        dup (representable-as-float?)
        [ >float @ ] [ frexp [ @ ] [ _ * ] bi* + ] if
    ] call ; inline

PRIVATE>

M: bignum log [ log ] log-2 (bignum-log) ;

GENERIC: log1+ ( x -- y )

M: object log1+ 1 + log ; inline

M: float log1+ dup -1.0 >= [ flog1+ ] [ 1.0 + 0.0 rect> log ] if ; inline

: 10^ ( x -- y ) 10 swap ^ ; inline

GENERIC: log10 ( x -- y ) foldable

M: real log10 >float flog10 ; inline

M: complex log10 log 10 log / ; inline

M: bignum log10 [ log10 ] log10-2 (bignum-log) ;

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
    dup [-1,1]? [ >float facos ] [ asin pi 2 / swap - ] if ;
    inline

GENERIC: atan ( x -- y ) foldable

M: complex atan i* atanh i* ; inline

M: float atan fatan ; inline

M: real atan >float atan ; inline

: asec ( x -- y ) recip acos ; inline

: acosec ( x -- y ) recip asin ; inline

: acot ( x -- y ) recip atan ; inline

: truncate ( x -- y ) dup 1 mod - ; inline

: round ( x -- y ) dup sgn 2 / + truncate ; inline

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
    [ iota [ ^ * ] with with map ] tri ;

: sigmoid ( x -- y ) neg e^ 1 + recip ; inline

GENERIC: signum ( x -- y )

M: real signum sgn ;

M: complex signum dup abs / ;

MATH: copysign ( x y -- x' )

M: real copysign >float copysign ;

M: float copysign
    [ double>bits ] [ fp-sign ] bi*
    [ 63 2^ bitor ] [ 63 2^ bitnot bitand ] if
    bits>double ;
