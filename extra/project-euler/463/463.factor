! Copyright (c) 2023 Cecilia Knaebchen.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel locals math math.functions
project-euler.common ;
IN: project-euler.463

! https://projecteuler.net/problem=463

! DESCRIPTION
! -----------

! The function f is defined for all positive integers as
! follows:

! f(1) = 1
! f(3) = 3
! f(2n) = f(n)
! f(4n+1) = 2f(2n+1) - f(n)
! f(4n+3) = 3f(2n+1) - 2f(n)

! The function S(n) is defined as Σ_{i=1}^n f(i)

! S(8) = 22 and S(100) = 3604

! Find S(3^37). Give the last 9 digits of your answer.


! SOLUTION
! --------

! Recursion for S(n):
! S(n) = S([n/2]) + 2S([(n+1)/2]) + 3S([(n-1)/2]) -
!        2S([(n+1)/4]) - 4S([(n-1)/4]) - 2S([(n-3)/4]) - 1

MEMO:: S ( n -- Sn )
    n {
        { -1 [ 0 ] }
        { 0 [ 0 ] }
        { 1 [ 1 ] }
        [
            drop n 2 /i S
            n 1 + 2 /i S 2 * +
            n 1 - 2 /i S 3 * +
            n 1 + 4 /i S 2 * -
            n 1 - 4 /i S 4 * -
            n 3 - 4 /i S 2 * - 1 -
        ]
    } case ;

: euler463 ( -- answer )
    3 37 ^ S 1000000000 mod ;

! [ euler463 ] time
! 0.14 ms

SOLUTION: euler463
