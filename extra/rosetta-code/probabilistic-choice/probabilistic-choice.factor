! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators.random formatting kernel
math quotations sequences ;
IN: rosettacode.probabilistic-choice

! https://rosettacode.org/wiki/Probabilistic_choice

! Given a mapping between items and their required probability
! of occurrence, generate a million items randomly subject to the
! given probabilities and compare the target probability of
! occurrence versus the generated values.

! The total of all the probabilities should equal one. (Because
! floating point arithmetic is involved this is subject to
! rounding errors).

! Use the following mapping to test your programs:
! aleph   1/5.0
! beth    1/6.0
! gimel   1/7.0
! daleth  1/8.0
! he      1/9.0
! waw     1/10.0
! zayin   1/11.0
! heth    1759/27720 # adjusted so that probabilities add to 1

CONSTANT: data
{
    { "aleph"   1/5.0 }
    { "beth"    1/6.0 }
    { "gimel"   1/7.0 }
    { "daleth"  1/8.0 }
    { "he"      1/9.0 }
    { "waw"     1/10.0 }
    { "zayin"   1/11.0 }
    { "heth"    f }
}

MACRO: case-probas ( data -- quot )
    [ first2 [ 1quotation ] dip [ swap 2array ] when* ] map 1quotation ;

: expected ( data name -- float )
    dupd of or* [ values sift sum 1 swap - ] unless ;

: generate ( # case-probas -- seq )
    H{ } clone [
        '[ _ casep _ inc-at ] times
    ] keep ; inline

: normalize ( seq # -- seq )
    [ clone ] dip '[ _ /f ] assoc-map ;

: summarize1 ( name value data -- )
    pick expected "%6s: %10f %10f\n" printf ;

: summarize ( generated data -- )
    "Key" "Value" "expected" "%6s  %10s %10s\n" printf
    '[ _ summarize1 ] assoc-each ;

: generate-normalized ( # proba -- seq )
    [ generate ] [ drop normalize ] 2bi ; inline

: example ( # data -- )
    [ case-probas generate-normalized ]
    [ summarize ] bi ; inline
