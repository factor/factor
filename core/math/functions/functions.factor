! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel math.constants math.libm combinators ;
IN: math.functions

GENERIC: (^) ( x y -- z ) foldable

: ^n ( z w -- z^w )
    1 swap [
        [ dupd * ] when >r sq r>
    ] each-bit nip ; inline

M: integer (^)
    dup 0 < [ neg ^n recip ] [ ^n ] if ;

: ^ ( x y -- z )
    over zero? [
        dup zero?
        [ 2drop 0.0 0.0 / ] [ 0 < [ drop 1.0 0.0 / ] when ] if
    ] [
        (^)
    ] if ; inline

: (^mod) ( n x y -- z )
    1 swap [
        [ dupd * pick mod ] when >r sq over mod r>
    ] each-bit 2nip ; inline

: gcd ( x y -- d )
    dup zero?
    [ drop dup 0 < [ neg ] when ] [ tuck mod gcd ] if ; foldable

: lcm ( a b -- c )
    [ * ] 2keep gcd /i ; foldable

: (mod-inv) ( b a y x -- a )
    dup zero? [
        drop nip dup 1 number= swap -1 number= or
        [ "Non-trivial divisor found" throw ] unless
    ] [
        tuck /mod >r pick * swap >r swapd - r> r> (mod-inv)
    ] if ; foldable

: mod-inv ( x y -- a )
    0 -rot 1 -rot (mod-inv) ; foldable

: ^mod ( x y n -- z )
    over 0 < [
        [ >r neg r> ^mod ] keep mod-inv
    ] [
        -rot (^mod)
    ] if ; foldable

GENERIC: abs ( x -- y ) foldable

GENERIC: absq ( x -- y ) foldable

: ~abs ( x y epsilon -- ? )
    >r - abs r> < ;

: ~rel ( x y epsilon -- ? )
    >r [ - abs ] 2keep [ abs ] 2apply + r> * < ;

: ~ ( x y epsilon -- ? )
    {
        { [ pick fp-nan? pick fp-nan? or ] [ 3drop f ] }
        { [ dup zero? ] [ drop number= ] }
        { [ dup 0 < ] [ ~rel ] }
        { [ t ] [ ~abs ] }
    } cond ;

: power-of-2? ( n -- ? )
    dup 0 < [ drop f ] [ dup 1- bitand zero? ] if ; foldable

: align ( m w -- n ) 1- [ + ] keep bitnot bitand ; inline

: log2 ( n -- b )
    {
        { [ dup 0 <= ] [ "log2 expects positive inputs" throw ] }
        { [ dup 1 number= ] [ drop 0 ] }
        { [ t ] [ -1 shift log2 1+ ] }
    } cond ; foldable

: conjugate ( z -- z* ) >rect neg rect> ; inline

: arg ( z -- arg ) >float-rect swap fatan2 ; inline

: >polar ( z -- abs arg )
    >float-rect [ [ sq ] 2apply + fsqrt ] 2keep swap fatan2 ;
    inline

: cis ( arg -- z ) dup fcos swap fsin rect> ; inline

: polar> ( abs arg -- z ) cis * ; inline

: ^mag ( w abs arg -- magnitude )
    >r >r >float-rect swap r> swap fpow r> rot * fexp /f ;
    inline

: ^theta ( w abs arg -- theta )
    >r >r >float-rect r> flog * swap r> * + ; inline

M: number (^)
    swap >polar 3dup ^theta >r ^mag r> polar> ;

: exp ( x -- y ) >rect swap fexp swap polar> ; inline

: log ( x -- y ) >polar swap flog swap rect> ; inline

: cos ( x -- y )
    >float-rect 2dup
    fcosh swap fcos * -rot
    fsinh swap fsin neg * rect> ; foldable

: sec ( x -- y ) cos recip ; inline

: cosh ( x -- y )
    >float-rect 2dup
    fcos swap fcosh * -rot
    fsin swap fsinh * rect> ; foldable

: sech ( x -- y ) cosh recip ; inline

: sin ( x -- y )
    >float-rect 2dup
    fcosh swap fsin * -rot
    fsinh swap fcos * rect> ; foldable

: cosec ( x -- y ) sin recip ; inline

: sinh ( x -- y )
    >float-rect 2dup
    fcos swap fsinh * -rot
    fsin swap fcosh * rect> ; foldable

: cosech ( x -- y ) sinh recip ; inline

: tan ( x -- y ) dup sin swap cos / ; inline

: tanh ( x -- y ) dup sinh swap cosh / ; inline

: cot ( x -- y ) dup cos swap sin / ; inline

: coth ( x -- y ) dup cosh swap sinh / ; inline

: acosh ( x -- y ) dup sq 1- sqrt + log ; inline

: asech ( x -- y ) recip acosh ; inline

: asinh ( x -- y ) dup sq 1+ sqrt + log ; inline

: acosech ( x -- y ) recip asinh ; inline

: atanh ( x -- y ) dup 1+ swap 1- neg / log 2 / ; inline

: acoth ( x -- y ) recip atanh ; inline

: [-1,1]? ( x -- ? )
    dup complex? [ drop f ] [ abs 1 <= ] if ; inline

: asin ( x -- y )
    dup [-1,1]? [ >float fasin ] [ i * asinh -i * ] if ; inline

: acos ( x -- y )
    dup [-1,1]? [ >float facos ] [ asin pi 2 / swap - ] if ;
    inline

: atan ( x -- y )
    dup [-1,1]? [ >float fatan ] [ i * atanh i * ] if ; inline

: asec ( x -- y ) recip acos ; inline

: acosec ( x -- y ) recip asin ; inline

: acot ( x -- y ) recip atan ; inline
