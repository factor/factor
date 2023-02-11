! Copyright (C) 2015 Alexander Ilin, Doug Coleman, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel math ranges math.statistics math.vectors
prettyprint random sequences sorting ;
IN: rosetta-code.dice7

! https://rosettacode.org/wiki/Seven-sided_dice_from_five-sided_dice

! Given an equal-probability generator of one of the integers 1
! to 5 as dice5; create dice7 that generates a pseudo-random
! integer from 1 to 7 in equal probability using only dice5 as a
! source of random numbers, and check the distribution for at
! least 1000000 calls using the function created in Simple
! Random Distribution Checker.

! Implementation suggestion: dice7 might call dice5 twice,
! re-call if four of the 25 combinations are given, otherwise
! split the other 21 combinations into 7 groups of three, and
! return the group index from the rolls.

! https://rosettacode.org/wiki/Simple_Random_Distribution_Checker

! Create a function to check that the random integers returned
! from a small-integer generator function have uniform
! distribution.

! The function should take as arguments:

! * The function (or object) producing random integers.
! * The number of times to call the integer generator.
! * A 'delta' value of some sort that indicates how close to a
!   flat distribution is close enough.

! The function should produce:

! * Some indication of the distribution achieved.
! * An 'error' if the distribution is not flat enough.

! Show the distribution checker working when the produced
! distribution is flat enough and when it is not. (Use a
! generator from Seven-dice from Five-dice).

! Output a random integer 1..5.
: dice5 ( -- x )
    5 [1..b] random ;

! Output a random integer 1..7 using dice5 as randomness source.
: dice7 ( -- x )
    0 [ dup 21 < ] [
        drop dice5 5 * dice5 + 6 -
    ] do until 7 rem 1 + ;

! Count the number of rolls for each side of the dice,
! inserting zeros for die rolls that never occur.
: count-outcomes ( #sides rolls -- counts )
    histogram
    swap [1..b] [ over [ 0 or ] change-at ] each
    sort-keys values ;

! Assumes a fair die [1..n] thrown for sum(counts),
! where n is length(counts).
: fair-counts? ( counts error -- ? )
    [
        [ ] [ sum ] [ length ] tri
        [ / v-n vabs ]
        [ drop v/n ] 2bi
    ] dip '[ _ < ] all? ;

! Verify distribution uniformity/naive. Error is the acceptable
! deviation from the ideal number of items in each bucket,
! expressed as a fraction of the total count.
:: test-distribution ( #sides #trials quot error -- )
    #sides #trials quot replicate count-outcomes :> outcomes
    outcomes .
    outcomes error fair-counts?
    "Random enough" "Not random enough" ? . ; inline

CONSTANT: trial-counts { 1 10 100 1000 10000 100000 1000000 }
CONSTANT: #sides 7
CONSTANT: error-delta 0.02

: verify-all ( -- )
    #sides trial-counts [
        [ dice7 ] error-delta test-distribution
    ] with each ;
