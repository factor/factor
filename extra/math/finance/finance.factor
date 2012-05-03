! Copyright (C) 2008 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel grouping sequences shuffle
math math.functions math.statistics math.vectors ;
IN: math.finance

<PRIVATE

: weighted ( x y a -- z )
    [ * ] [ 1 - neg * ] bi-curry bi* + ;

: a ( n -- a )
    1 + 2 swap / ;

PRIVATE>

: ema ( seq n -- newseq )
    a swap unclip [ swap pick weighted ] accumulate 2nip ;

: sma ( seq n -- newseq )
    clump [ mean ] map ;

: dema ( seq n -- newseq )
    [ ema ] keep [ drop 2 v*n ] [ ema ] 2bi v- ;

: gdema ( seq n v -- newseq )
    [ [ ema ] keep dupd ema ] dip
    [ 1 + v*n ] [ v*n ] bi-curry bi* v- ;

: tema ( seq n -- newseq )
    [ ema ] keep dupd [ ema ] keep
    [ drop [ 3 v*n ] bi@ v- ] [ ema nip ] 3bi v+ ;

: macd ( seq n1 n2 -- newseq )
    rot dup ema [ swap ema ] dip v- ;

: momentum ( seq n -- newseq )
    [ tail-slice ] 2keep [ dup length ] dip - head-slice v- ;

: monthly ( x -- y ) 12 / ; inline

: semimonthly ( x -- y ) 24 / ; inline

: biweekly ( x -- y ) 26 / ; inline

: weekly ( x -- y ) 52 / ; inline

: daily-360 ( x -- y ) 360 / ; inline

: daily-365 ( x -- y ) 365 / ; inline
