! Copyright (c) 2023 Cecilia Knaebchen.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel locals math math.functions ranges sequences
project-euler.common ;
IN: project-euler.508

! https://projecteuler.net/index.php?section=problems&id=508

! DESCRIPTION
! -----------

! Consider the Gaussian integer i-1. A base i-1 representation of a Gaussian integer a+bi is a finite sequence of digits
! d(n-1) d(n-2) ... d(1) d(0) such that:
! a+bi = d(n-1) (i-1)^(n-1) + ... + d(1) (i-1) + d(0)
! Each d(k) is in {0,1}
! There are no leading zeros, i.e. d(n-1) != 0, unless a+bi is itself 0

! Here are base i-1 representations of a few Gaussian integers:
! 11+24i -> 111010110001101
! 24-11i -> 110010110011
!  8+ 0i -> 111000000
! -5+ 0i -> 11001101
!  0+ 0i -> 0

! Remarkably, every Gaussian integer has a unique base i-1 representation!

! Define f(a+bi) as the number of 1s in the unique base i-1 representation of a+bi.
! For example, f(11+24i) = 9 and f(24-11i) = 7.

! Define B(L) as the sum of f(a+bi) for all integers a, b such that |a| <= L and |b| <= L.
! For example, B(500) = 10,795,060.

! Find B(10^15) mod 1,000,000,007.

! SOLUTION
! --------

! f(a+bi) = sum of digits in base i-1 representation of a+bi
! Recursion for f(a+bi):
!  x := (a+b) mod 2
!  -> f(a+bi) = f((x-a+b)/2 + (x-a-b)/2 * i) + x

MEMO:: fab ( a b -- n )
    a b [ zero? ] both? [ 0 ] [ a b + 2 rem dup a - dup [ b + 2 / ] [ b - 2 / ] bi* fab + ] if ;

! B(P,Q,R,S) := Sum(a=P..Q, b=R..S, f(a+bi))
! Recursion for B(P,Q,R,S) exists, basically four slightly different versions of B(-S/2,-R/2,P/2,Q/2)
! If summation is over fewer than 5000 terms, we just calculate values of f

MEMO:: B ( P Q R S -- n )
    Q P - S R - * 5000 <
    [
        P Q [a..b] R S [a..b] [ fab ] cartesian-map [ sum ] map-sum
    ]
    [
        S 2 / floor neg R 2 / ceiling neg P 2 / ceiling Q 2 / floor B
        S 2 / floor neg R 2 / ceiling neg P 1 - 2 / ceiling Q 1 - 2 / floor 4dup [ swap - 1 + ] 2bi@ * [ B ] dip +
        S 1 - 2 / floor neg R 1 - 2 / ceiling neg P 2 / ceiling Q 2 / floor 4dup [ swap - 1 + ] 2bi@ * 2 * [ B ] dip +
        S 1 - 2 / floor neg R 1 - 2 / ceiling neg P 1 + 2 / ceiling Q 1 + 2 / floor 4dup [ swap - 1 + ] 2bi@ * [ B ] dip +
        + + +
    ] if ;

: euler508 ( -- answer )
    10 15 ^ dup [ neg ] dip 2dup B 1000000007 mod ;

! [ euler508 ] time
! 19 ms

SOLUTION: euler508
