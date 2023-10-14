! Copyright (c) 2009 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.primes math.primes.factors
ranges project-euler.common sequences sequences.extras ;
IN: project-euler.069

! https://projecteuler.net/problem=69

! DESCRIPTION
! -----------

! Euler's Totient function, φ(n) [sometimes called the phi
! function], is used to determine the number of numbers less
! than n which are relatively prime to n. For example, as 1, 2,
! 4, 5, 7, and 8, are all less than nine and relatively prime to
! nine, φ(9)=6.

!     +----+------------------+------+-----------+
!     | n  | Relatively Prime | φ(n) | n / φ(n)  |
!     +----+------------------+------+-----------+
!     | 2  | 1                | 1    | 2         |
!     | 3  | 1,2              | 2    | 1.5       |
!     | 4  | 1,3              | 2    | 2         |
!     | 5  | 1,2,3,4          | 4    | 1.25      |
!     | 6  | 1,5              | 2    | 3         |
!     | 7  | 1,2,3,4,5,6      | 6    | 1.1666... |
!     | 8  | 1,3,5,7          | 4    | 2         |
!     | 9  | 1,2,4,5,7,8      | 6    | 1.5       |
!     | 10 | 1,3,7,9          | 4    | 2.5       |
!     +----+------------------+------+-----------+

! It can be seen that n = 6 produces a maximum n / φ(n) for n ≤
! 10.

! Find the value of n ≤ 1,000,000 for which n / φ(n) is a
! maximum.


! SOLUTION
! --------

! Brute force

<PRIVATE

: totient-ratio ( n -- m )
    dup totient / ;

PRIVATE>

: euler069 ( -- answer )
    2 1000000 [a..b] [ totient-ratio ] map
    arg-max 2 + ;

! [ euler069 ] 10 ave-time
! 25210 ms ave run time - 115.37 SD (10 trials)


! ALTERNATE SOLUTIONS
! -------------------

! In order to obtain maximum n / φ(n), φ(n) needs to be low and n needs to be
! high. Hence we need a number that has the most factors. A number with the
! most unique factors would have fewer relatively prime.

<PRIVATE

: primorial ( n -- m )
    {
        { [ dup 0 = ] [ drop V{ 1 } ] }
        { [ dup 1 = ] [ drop V{ 2 } ] }
        [ nth-prime primes-upto ]
    } cond product ;

: primorial-upto ( limit -- m )
    1 swap '[ dup primorial _ <= ] [ 1 + dup primorial ] produce
    nip penultimate ;

PRIVATE>

: euler069a ( -- answer )
    1000000 primorial-upto ;

! [ euler069a ] 100 ave-time
! 0 ms ave run time - 0.01 SD (100 trials)

SOLUTION: euler069a
