! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs fry kernel grouping math math.statistics math.vectors sequences ;

IN: math.finance

: enumerate ( seq -- newseq )
    <enum> >alist ;

<PRIVATE

: weighted ( x y a -- z ) 
    tuck [ * ] [ 1 swap - * ] 2bi* + ;

: a ( n -- a ) 
    1 + 2 swap / ;

: first-rest ( seq -- first rest )
    [ first ] keep 1 tail-slice ;

PRIVATE>

: ema ( seq n -- newseq )
    a swap first-rest swap '[ [ dup ] 2dip swap rot weighted ] accumulate 2nip ;

: sma ( seq n -- newseq )
    clump [ mean ] map ;

: macd ( seq n1 n2 -- newseq )
    rot dup ema [ swap ema ] dip v- ;

: momentum ( seq n -- newseq )
    2dup tail-slice -rot swap [ length ] keep
    [ - neg ] dip swap head-slice v- ;


