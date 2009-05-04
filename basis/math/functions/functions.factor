! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel math.constants math.private math.bits
math.libm combinators math.order sequences ;
IN: math.functions

: >fraction ( a/b -- a b )
    [ numerator ] [ denominator ] bi ; inline

: rect> ( x y -- z )
    dup 0 = [ drop ] [ complex boa ] if ; inline

GENERIC: sqrt ( x -- y ) foldable

M: real sqrt
    >float dup 0.0 < [ neg fsqrt 0.0 swap rect> ] [ fsqrt ] if ;

: factor-2s ( n -- r s )
    #! factor an integer into 2^r * s
    dup 0 = [ 1 ] [
        0 swap [ dup even? ] [ [ 1+ ] [ 2/ ] bi* ] while
    ] if ; inline

<PRIVATE

GENERIC# ^n 1 ( z w -- z^w )

: (^n) ( z w -- z^w )
    make-bits 1 [ [ dupd * ] when [ sq ] dip ] reduce nip ; inline

M: integer ^n
    [ factor-2s ] dip [ (^n) ] keep rot * shift ;

M: ratio ^n
    [ >fraction ] dip [ ^n ] curry bi@ / ;

M: float ^n
    (^n) ;

: integer^ ( x y -- z )
    dup 0 > [ ^n ] [ neg ^n recip ] if ; inline

PRIVATE>

: >rect ( z -- x y )
    [ real-part ] [ imaginary-part ] bi ; inline

: >float-rect ( z -- x y )
    >rect [ >float ] bi@ ; inline

: >polar ( z -- abs arg )
    >float-rect [ [ sq ] bi@ + fsqrt ] [ swap fatan2 ] 2bi ; inline

: cis ( arg -- z ) dup fcos swap fsin rect> ; inline

: polar> ( abs arg -- z ) cis * ; inline

<PRIVATE

: ^mag ( w abs arg -- magnitude )
    [ >float-rect swap ] [ swap fpow ] [ rot * fexp /f ] tri* ; inline

: ^theta ( w abs arg -- theta )
    [ >float-rect ] [ flog * swap ] [ * + ] tri* ; inline

: ^complex ( x y -- z )
    swap >polar [ ^mag ] [ ^theta ] 3bi polar> ; inline

: real^? ( x y -- ? )
    2dup [ real? ] both? [ drop 0 >= ] [ 2drop f ] if ; inline

: 0^ ( x -- z )
    dup zero? [ drop 0/0. ] [ 0 < 1/0. 0 ? ] if ; inline

: (^mod) ( n x y -- z )
    make-bits 1 [
        [ dupd * pick mod ] when [ sq over mod ] dip
    ] reduce 2nip ; inline

: (gcd) ( b a x y -- a d )
    over zero? [
        2nip
    ] [
        swap [ /mod [ over * swapd - ] dip ] keep (gcd)
    ] if ;

PRIVATE>

: ^ ( x y -- z )
    {
        { [ over zero? ] [ nip 0^ ] }
        { [ dup integer? ] [ integer^ ] }
        { [ 2dup real^? ] [ fpow ] }
        [ ^complex ]
    } cond ; inline

: gcd ( x y -- a d )
    [ 0 1 ] 2dip (gcd) dup 0 < [ neg ] when ; foldable

: lcm ( a b -- c )
    [ * ] 2keep gcd nip /i ; foldable

: divisor? ( m n -- ? )
    mod 0 = ;

: mod-inv ( x n -- y )
    [ nip ] [ gcd 1 = ] 2bi
    [ dup 0 < [ + ] [ nip ] if ]
    [ "Non-trivial divisor found" throw ] if ; foldable

: ^mod ( x y n -- z )
    over 0 < [
        [ [ neg ] dip ^mod ] keep mod-inv
    ] [
        -rot (^mod)
    ] if ; foldable

GENERIC: absq ( x -- y ) foldable

M: real absq sq ;

: ~abs ( x y epsilon -- ? )
    [ - abs ] dip < ;

: ~rel ( x y epsilon -- ? )
    [ [ - abs ] 2keep [ abs ] bi@ + ] dip * < ;

: ~ ( x y epsilon -- ? )
    {
        { [ 2over [ fp-nan? ] either? ] [ 3drop f ] }
        { [ dup zero? ] [ drop number= ] }
        { [ dup 0 < ] [ ~rel ] }
        [ ~abs ]
    } cond ;

: conjugate ( z -- z* ) >rect neg rect> ; inline

: arg ( z -- arg ) >float-rect swap fatan2 ; inline

: [-1,1]? ( x -- ? )
    dup complex? [ drop f ] [ abs 1 <= ] if ; inline

: >=1? ( x -- ? )
    dup complex? [ drop f ] [ 1 >= ] if ; inline

GENERIC: exp ( x -- y )

M: real exp fexp ;

M: complex exp >rect swap fexp swap polar> ;

GENERIC: log ( x -- y )

M: real log dup 0.0 >= [ flog ] [ 0.0 rect> log ] if ;

M: complex log >polar swap flog swap rect> ;

GENERIC: cos ( x -- y ) foldable

M: complex cos
    >float-rect
    [ [ fcos ] [ fcosh ] bi* * ]
    [ [ fsin neg ] [ fsinh ] bi* * ] 2bi rect> ;

M: real cos fcos ;

: sec ( x -- y ) cos recip ; inline

GENERIC: cosh ( x -- y ) foldable

M: complex cosh
    >float-rect
    [ [ fcosh ] [ fcos ] bi* * ]
    [ [ fsinh ] [ fsin ] bi* * ] 2bi rect> ;

M: real cosh fcosh ;

: sech ( x -- y ) cosh recip ; inline

GENERIC: sin ( x -- y ) foldable

M: complex sin
    >float-rect
    [ [ fsin ] [ fcosh ] bi* * ]
    [ [ fcos ] [ fsinh ] bi* * ] 2bi rect> ;

M: real sin fsin ;

: cosec ( x -- y ) sin recip ; inline

GENERIC: sinh ( x -- y ) foldable

M: complex sinh
    >float-rect
    [ [ fsinh ] [ fcos ] bi* * ]
    [ [ fcosh ] [ fsin ] bi* * ] 2bi rect> ;

M: real sinh fsinh ;

: cosech ( x -- y ) sinh recip ; inline

GENERIC: tan ( x -- y ) foldable

M: complex tan [ sin ] [ cos ] bi / ;

M: real tan ftan ;

GENERIC: tanh ( x -- y ) foldable

M: complex tanh [ sinh ] [ cosh ] bi / ;

M: real tanh ftanh ;

: cot ( x -- y ) tan recip ; inline

: coth ( x -- y ) tanh recip ; inline

: acosh ( x -- y )
    dup sq 1- sqrt + log ; inline

: asech ( x -- y ) recip acosh ; inline

: asinh ( x -- y )
    dup sq 1+ sqrt + log ; inline

: acosech ( x -- y ) recip asinh ; inline

: atanh ( x -- y )
    [ 1+ ] [ 1- neg ] bi / log 2 / ; inline

: acoth ( x -- y ) recip atanh ; inline

: i* ( x -- y ) >rect neg swap rect> ;

: -i* ( x -- y ) >rect swap neg rect> ;

: asin ( x -- y )
    dup [-1,1]? [ fasin ] [ i* asinh -i* ] if ; inline

: acos ( x -- y )
    dup [-1,1]? [ facos ] [ asin pi 2 / swap - ] if ;
    inline

GENERIC: atan ( x -- y ) foldable

M: complex atan i* atanh i* ;

M: real atan fatan ;

: asec ( x -- y ) recip acos ; inline

: acosec ( x -- y ) recip asin ; inline

: acot ( x -- y ) recip atan ; inline

: truncate ( x -- y ) dup 1 mod - ; inline

: round ( x -- y ) dup sgn 2 / + truncate ; inline

: floor ( x -- y )
    dup 1 mod dup zero?
    [ drop ] [ dup 0 < [ - 1- ] [ - ] if ] if ; foldable

: ceiling ( x -- y ) neg floor neg ; foldable
