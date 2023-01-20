! Copyright (C) 2008 John Benediktsson, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: grouping kernel math math.statistics math.vectors
sequences ;
IN: math.finance

: sma ( seq n -- newseq )
    clump [ mean ] map ;

<PRIVATE

: weighted ( prev elt a -- newelt )
    [ 1 swap - * ] [ * ] bi-curry bi* + ; inline

: a ( n -- a )
    1 + 2 swap / ; inline

PRIVATE>

: ema ( seq n -- newseq )
    [ cut [ mean dup ] dip ] [ a ] bi
    [ weighted dup ] curry map nip swap prefix ;

: dema ( seq n -- newseq )
    [ ema ] keep [ drop 2 v*n ] [ ema ] 2bi
    [ length tail* ] keep v- ;

: gdema ( seq n v -- newseq )
    [ [ ema ] keep dupd ema ] dip
    [ 1 + v*n ] [ v*n ] bi-curry bi*
    [ length tail* ] keep v- ;

: tema ( seq n -- newseq )
    [ ema ] keep dupd [ ema ] keep
    [ drop [ 3 v*n ] bi@ [ length tail* ] keep v- ] [ ema nip ] 3bi
    [ length tail* ] keep v+ ;

: macd ( seq n1 n2 -- newseq )
    rot dup ema [ swap ema ] dip v- ;

: momentum ( seq n -- newseq )
    [ tail-slice ] 2keep [ dup length ] dip - head-slice v- ;

: performance ( seq -- newseq )
    dup first '[ _ [ - ] [ /f ] bi 100 * ] map ;

: monthly ( x -- y ) 12 / ; inline

: semimonthly ( x -- y ) 24 / ; inline

: biweekly ( x -- y ) 26 / ; inline

: weekly ( x -- y ) 52 / ; inline

: daily-360 ( x -- y ) 360 / ; inline

: daily-365 ( x -- y ) 365 / ; inline
