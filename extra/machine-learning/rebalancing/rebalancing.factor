! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs fry kernel math math.functions
math.statistics memoize random sequences sorting ;
IN: machine-learning.rebalancing

ERROR: probability-sum-not-one seq ;

: check-probabilities ( seq -- seq )
    dup sum 1.0 .00000000001 ~ [ probability-sum-not-one ] unless ;

: equal-probabilities ( n -- array )
    dup recip <array> ; inline

MEMO: probabilities-seq ( seq -- seq' )
    check-probabilities [ >float ] map cum-sum ;

: probabilities-quot ( seq -- quot )
    probabilities-seq
    '[ _ random-unit '[ _ > ] find drop ] ; inline

: stratified-sample ( stratified-sequences probability-sequence -- elt )
    probabilities-quot call swap nth random ; inline

: balance-labels ( X y n -- X' y' )
    [
        dup [ ] collect-index-by
        values dup length equal-probabilities
        '[
            _ _ _ _ stratified-sample
            '[ _ swap nth ] bi@ 2array
        ]
    ] dip swap replicate [ keys ] [ values ] bi ;

: skew-labels ( X y probs n -- X' y' )
    [
        [ dup [ ] collect-index-by sort-keys values ] dip
        '[
            _ _ _ _ stratified-sample
            '[ _ swap nth ] bi@ 2array
        ]
    ] dip swap replicate [ keys ] [ values ] bi ;
