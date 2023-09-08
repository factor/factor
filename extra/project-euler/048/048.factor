! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ranges project-euler.common
sequences ;
IN: project-euler.048

! https://projecteuler.net/problem=48

! DESCRIPTION
! -----------

! The series, 1^1 + 2^2 + 3^3 + ... + 10^10 = 10405071317.

! Find the last ten digits of the series,
! 1^1 + 2^2 + 3^3 + ... + 1000^1000.


! SOLUTION
! --------

: euler048 ( -- answer )
    1000 [1..b] [ dup ^ ] map-sum 10 10^ mod ;

! [ euler048 ] 100 ave-time
! 276 ms run / 1 ms GC ave time - 100 trials

SOLUTION: euler048
