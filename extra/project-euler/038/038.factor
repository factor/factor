! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges project-euler.common sequences ;
IN: project-euler.038

! https://projecteuler.net/index.php?section=problems&id=38

! DESCRIPTION
! -----------

! Take the number 192 and multiply it by each of 1, 2, and 3:

!     192 × 1 = 192
!     192 × 2 = 384
!     192 × 3 = 576

! By concatenating each product we get the 1 to 9 pandigital, 192384576. We
! will call 192384576 the concatenated product of 192 and (1,2,3)

! The same can be achieved by starting with 9 and multiplying by 1, 2, 3, 4,
! and 5, giving the pandigital, 918273645, which is the concatenated product of
! 9 and (1,2,3,4,5).

! What is the largest 1 to 9 pandigital 9-digit number that can be formed as
! the concatenated product of an integer with (1,2, ... , n) where n > 1?


! SOLUTION
! --------

! Only need to search 4-digit numbers starting with 9 since a 2-digit number
! starting with 9 would produce 8 or 11 digits, and a 3-digit number starting
! with 9 would produce 7 or 11 digits.

<PRIVATE

: (concat-product) ( accum n multiplier -- m )
    pick length 8 > [
        2drop digits>number
    ] [
        [ * number>digits append! ] 2keep 1 + (concat-product)
    ] if ;

: concat-product ( n -- m )
    V{ } clone swap 1 (concat-product) ;

PRIVATE>

: euler038 ( -- answer )
    9123 9876 [a..b] [ concat-product ] map [ pandigital? ] filter supremum ;

! [ euler038 ] 100 ave-time
! 11 ms ave run time - 1.5 SD (100 trials)

SOLUTION: euler038
