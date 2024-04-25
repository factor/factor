! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.order
project-euler.common ranges sequences ;
IN: project-euler.066

! https://projecteuler.net/problem=66

! DESCRIPTION
! -----------

! Consider quadratic Diophantine equations of the form:
! x² - Dy² = 1

! For example, when D = 13, the minimal solution in x is
! 649² - 13 × 180² = 1.

! It can be assumed that there are no solutions in positive
! integers when D is square.

! By finding minimal solutions in x for D = {2, 3, 5, 6, 7}, we
! obtain the following:
! 3² - 2 × 2² = 1
! 2² - 3 × 1² = 1
! 9² - 5 × 4² = 1
! 5² - 6 × 2² = 1
! 8² - 7 × 3² = 1

! Hence, by considering minimal solutions in x for D <= 7, the
! largest x is obtained when D = 5.

! Find the value of D <= 1000 in minimal solutions of x for
! which the largest value of x is obtained.


! SOLUTION
! --------

! https://www.isibang.ac.in/~sury/chakravala.pdf
! N = D
! x0 = p0 = [sqrt(N)]
! q0 = 1
! m0 = p0² - N
! x' ≡ -x (mod |m|), x' < sqrt(N) < x'+|m|
! p' = (px'+Nq)/|m|
! q' = (p+x'q)/|m|
! m' = (x'²-N)/m

:: chakravala ( n x p q m -- n x' p' q' m' )
    n sqrt ceiling >integer :> upper-bound
    upper-bound m abs - :> lower-bound
    x neg m abs rem :> reminder
    lower-bound reminder - :> distance
    reminder distance m abs / ceiling 0 max m abs * + :> x'
    n
    x'
    p x' * n q * + m abs /
    p x' q * + m abs /
    x' sq n - m / ;

:: minimal-x ( D -- x )
    D sqrt floor >integer :> p0
    p0 sq D - :> m0
    D p0 p0 1 m0
    [ dup 1 = ] [ chakravala ] do until 2drop 2nip ;

: euler066 ( -- D )
    1000 [1..b] [ perfect-square? ] reject
    [ minimal-x ] maximum-by ;

SOLUTION: euler066
