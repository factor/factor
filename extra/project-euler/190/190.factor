! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel sequences math math.functions ranges project-euler.common ;
IN: project-euler.190

! https://projecteuler.net/index.php?section=problems&id=190

! DESCRIPTION
! -----------

! Let Sm = (x1, x2, ... , xm) be the m-tuple of positive real numbers
! with x1 + x2 + ... + xm = m for which Pm = x1 * x22 * ... * xmm is
! maximized.

! For example, it can be verified that [P10] = 4112 ([ ] is the integer
! part function).

! Find Σ[Pm] for 2 ≤ m ≤ 15.


! SOLUTION
! --------

! Pm = x1 * x2^2 * x3^3 * ... * xm^m
! fm = x1 + x2 + x3 + ... + xm - m = 0
! Gm === Pm - L * fm
! dG/dx_i = 0 = i * Pm / xi - L
! xi = i * Pm / L

! Sum(i=1 to m) xi = m
! Sum(i=1 to m) i * Pm / L = m
! Pm / L * Sum(i=1 to m) i = m
! Pm / L * m*(m+1)/2 = m
! Pm / L = 2 / (m+1)

! xi = i * (2 / (m+1)) = 2*i/(m+1)

<PRIVATE

: PI ( seq quot -- n )
    [ * ] compose 1 swap reduce ; inline

PRIVATE>

:: P_m ( m -- P_m )
    m [1..b] [| i | 2 i * m 1 + / i ^ ] PI ;

: euler190 ( -- answer )
    2 15 [a..b] [ P_m truncate ] map-sum ;

! [ euler150 ] 100 ave-time
! 5 ms ave run time - 1.01 SD (100 trials)

SOLUTION: euler190
