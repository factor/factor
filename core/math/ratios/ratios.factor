! Copyright (C) 2004, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math ;
IN: math.ratios

: 2>fraction ( a/b c/d -- a c b d )
    [ >fraction ] bi@ swapd ; inline

<PRIVATE

: fraction> ( a b -- a/b )
    dup 1 number= [ drop ] [ ratio boa ] if ; inline

: (scale) ( a b c d -- a*d b*c )
    [ * swap ] dip * swap ; inline

: scale ( a/b c/d -- a*d b*c )
    2>fraction (scale) ; inline

: scale+d ( a/b c/d -- a*d b*c b*d )
    2>fraction [ (scale) ] 2keep * ; inline

PRIVATE>

ERROR: division-by-zero x ;

M: integer /
    [
        division-by-zero
    ] [
        dup 0 < [ [ neg ] bi@ ] when
        2dup simple-gcd [ /i ] curry bi@ fraction>
    ] if-zero ;

M: integer recip
    1 swap [
        division-by-zero
    ] [
        dup 0 < [ [ neg ] bi@ ] when fraction>
    ] if-zero ;

M: ratio recip
    >fraction swap dup 0 < [ [ neg ] bi@ ] when fraction> ;

M: ratio hashcode*
    nip >fraction [ hashcode ] bi@ bitxor ;

M: ratio equal?
    over ratio? [
        2>fraction = [ = ] [ 2drop f ] if
    ] [ 2drop f ] if ;

M: ratio number=
    2>fraction number= [ number= ] [ 2drop f ] if ;

M: ratio >fixnum >fraction /i >fixnum ;
M: ratio >bignum >fraction /i >bignum ;
M: ratio >float >fraction /f ;

M: ratio numerator numerator>> ; inline
M: ratio denominator denominator>> ; inline
M: ratio >fraction [ numerator ] [ denominator ] bi ; inline

M: ratio < scale < ;
M: ratio <= scale <= ;
M: ratio > scale > ;
M: ratio >= scale >= ;

M: ratio + scale+d [ + ] [ / ] bi* ;
M: ratio - scale+d [ - ] [ / ] bi* ;
M: ratio * 2>fraction [ * ] 2bi@ / ;
M: ratio / scale / ;
M: ratio /i scale /i ;
M: ratio /f scale /f ;
M: ratio mod scale+d [ mod ] [ / ] bi* ;
M: ratio /mod scale+d [ /mod ] [ / ] bi* ;
M: ratio abs dup neg? [ >fraction [ neg ] dip fraction> ] when ;
M: ratio neg? numerator neg? ; inline
