! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math lists lists.lazy project-euler.common
sequences ;
IN: project-euler.065

! https://projecteuler.net/problem=65

! DESCRIPTION
! -----------

! The square root of 2 can be written as an infinite continued
! fraction.

!                      1
! √2 = 1 + -------------------------
!                        1
!          2 + ---------------------
!                          1
!              2 + -----------------
!                            1
!                  2 + -------------
!                      2 + ...

! The infinite continued fraction can be written, √2 = [1;(2)],
! (2) indicates that 2 repeats ad infinitum. In a similar way,
! √23 = [4;(1,3,1,8)].

! It turns out that the sequence of partial values of continued
! fractions for square roots provide the best rational
! approximations. Let us consider the convergents for √2.

!     1   3         1     7           1       17             1         41
! 1 + - = - ; 1 + ----- = - ; 1 + --------- = -- ; 1 + ------------- = --
!     2   2           1   5             1     12               1       29
!                 2 + -           2 + -----            2 + ---------
!                     2                   1                      1
!                                     2 + -                2 + -----
!                                         2                        1
!                                                              2 + -
!                                                                  2

! Hence the sequence of the first ten convergents for √2 are: 1,
! 3/2, 7/5, 17/12, 41/29, 99/70, 239/169, 577/408, 1393/985,
! 3363/2378, ...

! What is most surprising is that the important mathematical
! constant, e = [2; 1,2,1, 1,4,1, 1,6,1 , ... , 1,2k,1, ...].

! The first ten terms in the sequence of convergents for e are:
! 2, 3, 8/3, 11/4, 19/7, 87/32, 106/39, 193/71, 1264/465,
! 1457/536, ...

! The sum of digits in the numerator of the 10th convergent is
! 1+4+5+7=17.

! Find the sum of digits in the numerator of the 100th
! convergent of the continued fraction for e.


! SOLUTION
! --------

<PRIVATE

: (e-frac) ( -- seq )
    2 lfrom [
        dup 3 mod zero? [ 3 / 2 * ] [ drop 1 ] if
    ] lmap-lazy ;

: e-frac ( n -- n )
    1 - (e-frac) ltake list>array reverse 0
    [ + recip ] reduce 2 + ;

PRIVATE>

: euler065 ( -- answer )
    100 e-frac numerator number>digits sum ;

! [ euler065 ] 100 ave-time
! 4 ms ave run time - 0.33 SD (100 trials)

SOLUTION: euler065
