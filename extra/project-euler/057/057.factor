! Copyright (c) 2008 Samuel Tardieu
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.parser math.ranges project-euler.common
    sequences ;
IN: project-euler.057

! http://projecteuler.net/index.php?section=problems&id=57

! DESCRIPTION
! -----------

! It is possible to show that the square root of two can be expressed
! as an infinite continued fraction.

!     √ 2 = 1 + 1/(2 + 1/(2 + 1/(2 + ... ))) = 1.414213...

! By expanding this for the first four iterations, we get:

!     1 + 1/2 = 3/2 = 1.5
!     1 + 1/(2 + 1/2) = 7/5 = 1.4
!     1 + 1/(2 + 1/(2 + 1/2)) = 17/12 = 1.41666...
!     1 + 1/(2 + 1/(2 + 1/(2 + 1/2))) = 41/29 = 1.41379...

! The next three expansions are 99/70, 239/169, and 577/408, but the
! eighth expansion, 1393/985, is the first example where the number of
! digits in the numerator exceeds the number of digits in the
! denominator.

! In the first one-thousand expansions, how many fractions contain a
! numerator with more digits than denominator?

! SOLUTION
! --------

: longer-numerator? ( seq -- ? )
    >fraction [ number>string length ] bi@ > ; inline

: euler057 ( -- answer )
    0 1000 [0,b) [ drop 2 + recip dup 1 + longer-numerator? ] count nip ;

! [ euler057 ] 100 ave-time
! 1728 ms ave run time - 80.81 SD (100 trials)

SOLUTION: euler057
