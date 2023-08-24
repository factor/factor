! Copyright (c) 2007 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ranges sequences project-euler.common ;
IN: project-euler.173

! https://projecteuler.net/index.php?section=problems&id=173

! DESCRIPTION
! -----------

! We shall define a square lamina to be a square outline with a square "hole"
! so that the shape possesses vertical and horizontal symmetry. For example,
! using exactly thirty-two square tiles we can form two different square
! laminae: [see URL for figure]

! With one-hundred tiles, and not necessarily using all of the tiles at one
! time, it is possible to form forty-one different square laminae.

! Using up to one million tiles how many different square laminae can be formed?


! SOLUTION
! --------

<PRIVATE

: laminae ( upper -- n )
    4 / dup sqrt [1..b] 0 rot [ over /i - - ] curry reduce ;

PRIVATE>

: euler173 ( -- answer )
    1000000 laminae ;

! [ euler173 ] 100 ave-time
! 0 ms ave run time - 0.35 SD (100 trials)

SOLUTION: euler173
