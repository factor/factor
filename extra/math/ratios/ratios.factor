! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.functions math.private ;
IN: math.ratios

: >fraction ( a/b -- a b )
    dup numerator swap denominator ; inline

: 2>fraction ( a/b c/d -- a c b d )
    [ >fraction ] bi@ swapd ; inline

<PRIVATE

: fraction> ( a b -- a/b )
    dup 1 number= [ drop ] [ <ratio> ] if ; inline

: scale ( a/b c/d -- a*d b*c )
    2>fraction >r * swap r> * swap ; inline

: ratio+d ( a/b c/d -- b*d )
    denominator swap denominator * ; inline

PRIVATE>

M: integer /
    dup zero? [
        "Division by zero" throw
    ] [
        dup 0 < [ [ neg ] bi@ ] when
        2dup gcd nip tuck /i >r /i r> fraction>
    ] if ;

M: ratio number=
    2>fraction number= [ number= ] [ 2drop f ] if ;

M: ratio >fixnum >fraction /i >fixnum ;
M: ratio >bignum >fraction /i >bignum ;
M: ratio >float >fraction /f ;

M: ratio numerator numerator>> ;
M: ratio denominator denominator>> ;

M: ratio < scale < ;
M: ratio <= scale <= ;
M: ratio > scale > ;
M: ratio >= scale >= ;

M: ratio + 2dup scale + -rot ratio+d / ;
M: ratio - 2dup scale - -rot ratio+d / ;
M: ratio * 2>fraction * >r * r> / ;
M: ratio / scale / ;
M: ratio /i scale /i ;
M: ratio /f scale /f ;
M: ratio mod 2dup >r >r /i r> r> rot * - ;
M: ratio /mod [ /i ] 2keep mod ;
