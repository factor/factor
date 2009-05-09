! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.ranges project-euler.common sequences ;
IN: project-euler.048

! http://projecteuler.net/index.php?section=problems&id=48

! DESCRIPTION
! -----------

! The series, 1^1 + 2^2 + 3^3 + ... + 10^10 = 10405071317.

! Find the last ten digits of the series, 1^1 + 2^2 + 3^3 + ... + 1000^1000.


! SOLUTION
! --------

: euler048 ( -- answer )
    1000 [1,b] [ dup ^ ] sigma 10 10 ^ mod ;

! [ euler048 ] 100 ave-time
! 276 ms run / 1 ms GC ave time - 100 trials

SOLUTION: euler048
