! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays kernel grouping math math.statistics sequences ;

IN: math.finance

: enumerate ( seq -- newseq )
    #! Returns a sequence where each element and its index
    -1 swap [ [ 1+ ] dip swap [ 2array ] keep swap ] { } map-as swap drop ;

: ema ( seq n -- newseq )
    #! An exponentially-weighted moving average:
    #! A = 2.0 / (N + 1)
    #! EMA[t] = (A * VAL[t]) + ((1-A) * EMA[t-1])
    1+ 2.0 swap / dup 1 swap - swap rot
    [ [ dup ] dip * ] map swap drop 0 swap
    [ [ dup ] 2dip [ * ] dip + dup ] map 
    [ drop drop ] dip 1 tail-slice >array ;

: sma ( seq n -- newseq )
    #! Simple moving average
    clump [ mean ] map ;

: macd ( seq n1 n2 -- newseq )
    #! Moving Average Convergence Divergence
    #! MACD[t] = EMA2[t] - EMA1[t]
    rot dup ema [ swap ema ] dip [ - ] 2map ;

: momentum ( seq n -- newseq )
    #! Momentum
    #! M[t] = P[t] - P[t-n]
    2dup tail-slice -rot swap [ length ] keep
    [ - neg ] dip swap head-slice [ - ] 2map ;


