! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions project-euler.common ;
IN: project-euler.100

! https://projecteuler.net/problem=100

! DESCRIPTION
! -----------

! If a box contains twenty-one colored discs, composed of
! fifteen blue discs and six red discs, and two discs were taken
! at random, it can be seen that the probability of taking two
! blue discs, P(BB) = (15/21)*(14/20) = 1/2.

! The next such arrangement, for which there is exactly 50%
! chance of taking two blue discs at random, is a box containing
! eighty-five blue discs and thirty-five red discs.

! By finding the first arrangement to contain over 10^12 =
! 1,000,000,000,000 discs in total, determine the number of blue
! discs that the box would contain.


! SOLUTION
! --------

: euler100 ( -- answer )
    1 1
    [ dup dup 1 - * 2 * 10 24 ^ <= ]
    [ [ 6 * swap - 2 - ] guard ] while nip ;

! TODO: solution needs generalization

! [ euler100 ] 100 ave-time
! 0 ms ave run time - 0.14 SD (100 trials)

SOLUTION: euler100
