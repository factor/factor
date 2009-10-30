! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel lexer math
math.functions math.parser parser sequences splitting
locals math.order ;
IN: decimals

TUPLE: decimal { mantissa read-only } { exponent read-only } ;

: <decimal> ( mantissa exponent -- decimal ) decimal boa ;

: >decimal< ( decimal -- mantissa exponent )
    [ mantissa>> ] [ exponent>> ] bi ; inline

: string>decimal ( string -- decimal )
    "." split1
    [ [ CHAR: 0 = ] trim-head [ "0" ] when-empty ]
    [ [ CHAR: 0 = ] trim-tail [ "" ] when-empty ] bi*
    [ append string>number ] [ nip length neg ] 2bi <decimal> ; 

: parse-decimal ( -- decimal ) scan string>decimal ;

SYNTAX: D: parse-decimal suffix! ;

: decimal>ratio ( decimal -- ratio ) >decimal< 10^ * ;
: decimal>float ( decimal -- ratio ) decimal>ratio >float ;

: scale-mantissas ( D1 D2 -- m1 m2 exp )
    [ [ mantissa>> ] bi@ ]
    [ 
        [ exponent>> ] bi@
        [
            - dup 0 <
            [ neg 10^ * t ]
            [ 10^ [ * ] curry dip f ] if
        ] [ ? ] 2bi
    ] 2bi ;

: scale-decimals ( D1 D2 -- D1' D2' )
    scale-mantissas tuck [ <decimal> ] 2dip <decimal> ;

ERROR: decimal-types-expected d1 d2 ;

: guard-decimals ( obj1 obj2 -- D1 D2 )
    2dup [ decimal? ] both?
    [ decimal-types-expected ] unless ;

M: decimal equal?
    {
        [ [ decimal? ] both? ]
        [
            scale-decimals
            {
                [ [ mantissa>> ] bi@ = ]
                [ [ exponent>> ] bi@ = ]
            } 2&&
        ]
    } 2&& ;

M: decimal before?
    guard-decimals scale-decimals
    [ mantissa>> ] bi@ < ;

: D-abs ( D -- D' )
    [ mantissa>> abs ] [ exponent>> ] bi <decimal> ;

: D+ ( D1 D2 -- D3 )
    guard-decimals scale-mantissas [ + ] dip <decimal> ;

: D- ( D1 D2 -- D3 )
    guard-decimals scale-mantissas [ - ] dip <decimal> ;

: D* ( D1 D2 -- D3 )
    guard-decimals [ >decimal< ] bi@ swapd + [ * ] dip <decimal> ;

:: D/ ( D1 D2 a -- D3 )
    D1 D2 guard-decimals 2drop
    D1 >decimal< :> ( m1 e1 )
    D2 >decimal< :> ( m2 e2 )
    m1 a 10^ *
    m2 /i
    
    e1
    e2 a + - <decimal> ;

M: decimal <=>
    2dup before? [ 2drop +lt+ ] [ equal? +eq+ +gt+ ? ] if ; inline
