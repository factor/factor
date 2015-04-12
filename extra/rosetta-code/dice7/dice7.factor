! Copyright (C) 2015 Alexander Ilin, Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs fry kernel locals math math.ranges math.statistics
math.vectors prettyprint random sequences sorting ;
IN: rosetta-code.dice7

! http://rosettacode.org/wiki/Seven-sided_dice_from_five-sided_dice
! http://rosettacode.org/wiki/Simple_Random_Distribution_Checker

! Output a random integer 1..5.
: dice5 ( -- x )
   5 [1,b] random ;

! Output a random integer 1..7 using dice5 as randomness source.
: dice7 ( -- x )
    0 [ dup 21 < ] [
        drop dice5 5 * dice5 + 6 -
   ] do until 7 rem 1 + ;

! Count the number of rolls for each side of the dice,
! inserting zeros for die rolls that never occur.
: count-outcomes ( #sides rolls -- counts )
    histogram
    swap [1,b] [ over [ 0 or ] change-at ] each
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
