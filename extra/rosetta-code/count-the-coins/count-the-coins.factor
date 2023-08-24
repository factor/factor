! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: arrays math ranges sequences sets sorting ;
IN: rosetta-code.count-the-coins

! https://rosettacode.org/wiki/Count_the_coins

! There are four types of common coins in US currency: quarters
! (25 cents), dimes (10), nickels (5) and pennies (1). There are 6
! ways to make change for 15 cents:

! A dime and a nickel;
! A dime and 5 pennies;
! 3 nickels;
! 2 nickels and 5 pennies;
! A nickel and 10 pennies;
! 15 pennies.

! How many ways are there to make change for a dollar using
! these common coins? (1 dollar = 100 cents).

! Optional:

! Less common are dollar coins (100 cents); very rare are half
! dollars (50 cents). With the addition of these two coins, how
! many ways are there to make change for $1000? (note: the answer
! is larger than 232).

<PRIVATE

:: (make-change) ( cents coins -- ways )
    cents 1 + 0 <array> :> ways
    1 ways set-first
    coins [| coin |
        coin cents [a..b] [| j |
            j coin - ways nth j ways [ + ] change-nth
        ] each
    ] each ways last ;

PRIVATE>

! How many ways can we make the given amount of cents
! with the given set of coins?
: make-change ( cents coins -- ways )
    members inv-sort (make-change) ;
