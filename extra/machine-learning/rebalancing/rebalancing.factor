! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math math.functions math.statistics
random sequences sorting ;
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

: stratified-samples ( stratified-sequences probability-sequence n -- elt )
    [ '[ _ _ stratified-sample ] ] dip swap replicate ;

: equal-stratified-sample ( stratified-sequences -- elt )
    random random ; inline

: collect-indices ( seq -- indices )
    H{ } clone [ '[ swap _ push-at ] each-index ] keep ;

: balance-labels ( X y n -- X' y' )
    [
        dup collect-indices
        values '[
            _ _ _ equal-stratified-sample
            '[ _ swap nth ] bi@ 2array
        ]
    ] dip swap replicate [ keys ] [ values ] bi ;

: skew-labels ( X y probs n -- X' y' )
    [
        [ dup collect-indices sort-keys values ] dip
        '[
            _ _ _ _ stratified-sample
            '[ _ swap nth ] bi@ 2array
        ]
    ] dip swap replicate [ keys ] [ values ] bi ;
