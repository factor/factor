! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math.ratios.private
USING: kernel kernel.private math math.functions
math.private ;

: fraction> ( a b -- a/b )
    dup 1 number= [ drop ] [ <ratio> ] if ; inline

M: integer /
    dup zero? [
        /i
    ] [
        dup 0 < [ [ neg ] 2apply ] when
        2dup gcd nip tuck /i >r /i r> fraction>
    ] if ;

: 2>fraction ( a/b c/d -- a c b d )
    [ >fraction ] 2apply swapd ; inline

: scale ( a/b c/d -- a*d b*c )
    2>fraction >r * swap r> * swap ; inline

: ratio+d ( a/b c/d -- b*d )
    denominator swap denominator * ; inline

M: ratio number=
    2>fraction number= [ number= ] [ 2drop f ] if ;

M: ratio >fixnum >fraction /i >fixnum ;
M: ratio >bignum >fraction /i >bignum ;
M: ratio >float >fraction /f ;

M: ratio < scale < ;
M: ratio <= scale <= ;
M: ratio > scale > ;
M: ratio >= scale >= ;

M: ratio + 2dup scale + -rot ratio+d / ;
M: ratio - 2dup scale - -rot ratio+d / ;
M: ratio * 2>fraction * >r * r> / ;
M: ratio / scale / ;
M: ratio /i scale /i ;
M: ratio mod 2dup >r >r /i r> r> rot * - ;
